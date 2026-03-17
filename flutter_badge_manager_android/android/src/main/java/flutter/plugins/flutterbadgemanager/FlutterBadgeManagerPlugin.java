package flutter.plugins.flutterbadgemanager;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import me.leolin.shortcutbadger.ShortcutBadger;

public class FlutterBadgeManagerPlugin
    implements FlutterPlugin, FlutterBadgeManagerPluginPigeon.FlutterBadgeManagerApi {

  @Nullable private Context applicationContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    applicationContext = binding.getApplicationContext();
    FlutterBadgeManagerPluginPigeon.FlutterBadgeManagerApi.setUp(
        binding.getBinaryMessenger(), this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    FlutterBadgeManagerPluginPigeon.FlutterBadgeManagerApi.setUp(
        binding.getBinaryMessenger(), null);
    applicationContext = null;
  }

  @Override
  public @Nullable Boolean isSupported() {
    return ShortcutBadger.isBadgeCounterSupported(requireContext());
  }

  @Override
  public void update(@NonNull Long count) {
    if (count < 0) {
      throw new FlutterBadgeManagerPluginPigeon.FlutterError(
          "invalid_args", "count must be non-negative int", null);
    }

    applyBadge(count.intValue());
  }

  @Override
  public void remove() {
    applyBadge(0);
  }

  private void applyBadge(int count) {
    if (count == 0) {
      ShortcutBadger.removeCount(requireContext());
      return;
    }

    ShortcutBadger.applyCount(requireContext(), count);
  }

  private @NonNull Context requireContext() {
    final Context context = applicationContext;
    if (context == null) {
      throw new IllegalStateException(
          "FlutterBadgeManagerPlugin is not attached to an engine.");
    }

    return context;
  }
}