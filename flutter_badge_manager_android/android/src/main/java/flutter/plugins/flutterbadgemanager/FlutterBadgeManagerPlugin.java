package flutter.plugins.flutterbadgemanager;

import android.content.Context;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import me.leolin.shortcutbadger.ShortcutBadger;

/**
 * FlutterBadgetManagerPlugin
 */
public class FlutterBadgetManagerPlugin implements MethodCallHandler, FlutterPlugin {

  private Context applicationContext;
  private MethodChannel channel;
  private static final String CHANNEL_NAME = "github.com/ziqq/flutter_badge_manager";

  /**
   * Plugin registration.
   */

  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    applicationContext = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding flutterPluginBinding) {
    channel.setMethodCallHandler(null);
    applicationContext = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    System.out.println(call.method);
    if (call.method.equals("update")) {
      System.out.println(Integer.valueOf(call.argument("count").toString()));
      ShortcutBadger.applyCount(applicationContext, Integer.valueOf(call.argument("count").toString()));
      result.success(null);
    } else if (call.method.equals("remove")) {
      ShortcutBadger.removeCount(applicationContext);
      result.success(null);
    } else if (call.method.equals("isSupported")) {
      result.success(ShortcutBadger.isBadgeCounterSupported(applicationContext));
    } else {
      result.notImplemented();
    }
  }
}
