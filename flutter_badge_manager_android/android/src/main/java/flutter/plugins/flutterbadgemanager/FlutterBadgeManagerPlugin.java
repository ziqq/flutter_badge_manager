package flutter.plugins.flutterbadgemanager;

import android.content.Context;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import flutter.plugins.flutterbadgemanager.generated.FlutterBadgeManager;
import me.leolin.shortcutbadger.ShortcutBadger;

public class FlutterBadgeManagerPlugin implements MethodCallHandler, FlutterPlugin, FlutterBadgeManager.FlutterBadgeManagerApi {

  private Context applicationContext;
  private MethodChannel channel;

  private static final String CHANNEL_NAME = "github.com/ziqq/flutter_badge_manager";
  private static final String NOTIF_CHANNEL_ID = "badge_channel";
  private static final int NOTIF_ID = 7001;
  // private static final boolean ENABLE_NOTIFICATION_BADGE = false;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    applicationContext = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    FlutterBadgeManager.FlutterBadgeManagerApi.setUp(binding.getBinaryMessenger(), this);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    FlutterBadgeManager.FlutterBadgeManagerApi.setUp(binding.getBinaryMessenger(), null);
    channel = null;
    applicationContext = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "isSupported": {
        result.success(isSupported());
        break;
      }
      case "update": {
        Integer count = safeCount(call.argument("count"));
        try {
          update(count == null ? null : count.longValue());
          result.success(null);
        } catch (FlutterBadgeManager.FlutterError error) {
          result.error(error.code, error.getMessage(), error.details);
        }
        break;
      }
      case "remove": {
        remove();
        result.success(null);
        break;
      }
      default:
        result.notImplemented();
    }
  }

  private Integer safeCount(Object raw) {
    if (raw == null) return null;
    if (raw instanceof Integer) return (Integer) raw;
    try { return Integer.valueOf(raw.toString()); } catch (Exception e) { return null; }
  }

  @Override
  public Boolean isSupported() {
    return ShortcutBadger.isBadgeCounterSupported(applicationContext);
  }

  @Override
  public void update(Long count) {
    if (count == null || count < 0) {
      throw new FlutterBadgeManager.FlutterError(
        "invalid_args",
        "count must be non-negative int",
        null
      );
    }
    applyBadge(count.intValue());
  }

  @Override
  public void remove() {
    applyBadge(0);
  }

  private void applyBadge(int count) {
    // Try ShortcutBadger if possible
    try {
      if (count == 0) {
        ShortcutBadger.removeCount(applicationContext);
      } else {
        ShortcutBadger.applyCount(applicationContext, count);
      }
    } catch (Exception ignored) {
      // Removed: all NotificationManager / NotificationChannel logic to avoid any user-visible notifications.
    }

    /* if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && ENABLE_NOTIFICATION_BADGE) {
      NotificationManager nm = (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
      if (nm == null) return;

      NotificationChannel ch = nm.getNotificationChannel(NOTIF_CHANNEL_ID);
      if (ch == null) {
        ch = new NotificationChannel(
          NOTIF_CHANNEL_ID,
          "Badge Updates",
          NotificationManager.IMPORTANCE_DEFAULT // Важность >= DEFAULT
        );
        ch.setShowBadge(true);
        nm.createNotificationChannel(ch);
      } else if (!ch.canShowBadge()) {
        ch.setShowBadge(true); // Для некоторых прошивок
      }

      if (count == 0) {
        nm.cancel(NOTIF_ID);
        return;
      }

      NotificationCompat.Builder builder = new NotificationCompat.Builder(applicationContext, NOTIF_CHANNEL_ID)
        .setSmallIcon(applicationContext.getApplicationInfo().icon)
        .setContentTitle("Badge")
        .setContentText("Unread: " + count)
        .setNumber(count) // Используется некоторыми лаунчерами
        .setBadgeIconType(NotificationCompat.BADGE_ICON_SMALL)
        .setAutoCancel(false)
        .setOngoing(false)
        .setPriority(NotificationCompat.PRIORITY_DEFAULT);

      Notification notification = builder.build();
      nm.notify(NOTIF_ID, notification);
    } */
  }
}