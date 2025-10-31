package flutter.plugins.flutterbadgemanager;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Build;

import androidx.core.app.NotificationCompat;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import me.leolin.shortcutbadger.ShortcutBadger;

public class FlutterBadgeManagerPlugin implements MethodCallHandler, FlutterPlugin {

  private Context applicationContext;
  private MethodChannel channel;

  private static final String CHANNEL_NAME = "github.com/ziqq/flutter_badge_manager";
  private static final String NOTIF_CHANNEL_ID = "badge_channel";
  private static final int NOTIF_ID = 7001;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    applicationContext = binding.getApplicationContext();
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    applicationContext = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "isSupported": {
        result.success(ShortcutBadger.isBadgeCounterSupported(applicationContext));
        break;
      }
      case "update": {
        Integer count = safeCount(call.argument("count"));
        if (count == null || count < 0) {
          result.error("invalid_args", "count must be non-negative int", null);
          return;
        }
        applyBadge(count);
        result.success(null);
        break;
      }
      case "remove": {
        applyBadge(0);
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

  private void applyBadge(int count) {
    // ShortcutBadger (попытаемся, если поддерживается)
    try {
      if (count == 0) {
        ShortcutBadger.removeCount(applicationContext);
      } else {
        ShortcutBadger.applyCount(applicationContext, count);
      }
    } catch (Exception ignored) {}

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
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
    }
  }
}