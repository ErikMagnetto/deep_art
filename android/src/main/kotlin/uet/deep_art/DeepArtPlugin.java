package uet.deep_art;

import android.os.Handler;

import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ArtisticStyleTransferPlugin */
public class DeepArtPlugin implements MethodCallHandler {
  /** Plugin registration. */
  private Registrar registrar;
  private StylizeActivity stylizeActivity;
  final private Handler mainHandler = new Handler();

  private DeepArtPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.stylizeActivity = new StylizeActivity(registrar.context());
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "artistic_style_transfer");
    channel.setMethodCallHandler(new DeepArtPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("styleTransfer")) {
//      final ArrayList<Integer> arrayListStyles = call.argument("styles");
//      final Integer[] styles = arrayListStyles.toArray(new Integer[arrayListStyles.size()]);
     final String inputFilePath = call.argument("inputFilePath");
     final String outputDir = call.argument("outputDir");
     final int number = call.argument("number");
//
//      final double styleFactorDouble = call.argument("styleFactor");
//      final float styleFactor = (float) styleFactorDouble;
//      final boolean convertToGrey = call.argument("convertToGrey");
        // final Bitmap bitmap = call.argument("bitmap");

      // new Thread(
      mainHandler.post(
        new Runnable() {
        @Override
        public void run() {
          try {
            final String output = stylizeActivity.styleTransfer(registrar.context(), inputFilePath, outputDir, number);
//                    styles, inputFilePath, outputFilePath, quality, styleFactor, convertToGrey);
            if(output!=null){
              result.success(output);
            } else {
              result.error("out of memory", "out of memory", "out of memory");
            }
          } catch (Exception e) {
            // stylizeActivity.freeUpMemory();
            result.error("styleTransfer", "error", e.toString());
            // print(e.toString());
          } catch (Error e){
            result.error("styleTransfer", "error", e.toString());
            // print(e.toString());
          }
        }})
        // .start()
        ;
    } else if (call.method.equals("realtimeTransfer")){
      // final List<Plane> planes = call.argument("planes");
      final int yRowStride = call.argument("yRowStride");
      final int uvRowStride = call.argument("uvRowStride");
      final int uvPixelStride = call.argument("uvPixelStride");
     final List<byte[]> byteList = call.argument("byteList");
     final int imgHeight = call.argument("imgHeight");
     final int imgWidth = call.argument("imgWidth");
     final int number = call.argument("number");
     
//
//      final double styleFactorDouble = call.argument("styleFactor");
//      final float styleFactor = (float) styleFactorDouble;
//      final boolean convertToGrey = call.argument("convertToGrey");
        // final Bitmap bitmap = call.argument("bitmap");

      // new Thread(
      mainHandler.post(
        new Runnable() {
        @Override
        public void run() {
          try {
            final String output = "a";
            // final String output = 
            stylizeActivity.realtimeTransfer(registrar.context(), yRowStride, uvRowStride, uvPixelStride, byteList, imgHeight, imgWidth, number);
//                    styles, inputFilePath, outputFilePath, quality, styleFactor, convertToGrey);
            if(output!=null){
              result.success(output);
            } else {
              result.error("out of memory", "out of memory", "out of memory");
            }
          } catch (Exception e) {
            // stylizeActivity.freeUpMemory();
            result.error("styleTransfer", "error", e.toString());
            // print(e.toString());
          } catch (Error e){
            result.error("styleTransfer", "error", e.toString());
            // print(e.toString());
          }
        }})
        // .start()
        ;
    }
  }
}


