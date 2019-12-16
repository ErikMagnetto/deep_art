package uet.deep_art;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.util.Log;
import android.widget.ImageView;

import org.tensorflow.contrib.android.TensorFlowInferenceInterface;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

// import android.support.v7.app.AppCompatActivity;
//import android.graphics.Matrix;

// import env.ImageUtils;

public class StylizeActivity {

    private static final String TAG = "MainActivity";

    //    private static final String MODEL_FILE = "file:///android_asset/frozen_la_muse.pb";
    private static final String MODEL_FILE = "file:///android_asset/style_graph_frozen_cloud.pb";
    private static final String INPUT_NODE = "X_inputs";
    private static final String OUTPUT_NODE = "output";

    private int[] intValues;
    private float[] floatValues;

    private ImageView ivPhoto;
    byte[][] yuvBytes;
    int[] rgbBytes = null;
    Bitmap rgbFrameBitmap = null;

    File photoFile;
    private FileInputStream is = null;
    private static final int CODE = 1;

    private TensorFlowInferenceInterface inferenceInterface;
    Bitmap bitmap;
    String modelFile;
    // Bitmap croppedBitmap;

    public StylizeActivity(Context context) {
        
    }

//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        setContentView(R.layout.activity_main);
//
//        ivPhoto = (ImageView) findViewById(R.id.ivPhoto);
//
//        Button onCamera = (Button) findViewById(R.id.onCamera);
//        onCamera.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
//                if (intent.resolveActivity(getPackageManager()) != null) {
//                    try {
//                        photoFile = createImageFile();  //创建临时图片文件，方法在下面
//                    } catch (IOException e) {
//                        e.printStackTrace();
//                    }
//                    if (photoFile != null) {
//                        //FileProvider 是一个特殊的 ContentProvider 的子类，它使用 content:// Uri 代替了 file:///
//                        // Uri. ，更便利而且安全的为另一个app分享文件
//                        Uri photoURI = FileProvider.getUriForFile(MainActivity.this,
//                                BuildConfig.APPLICATION_ID + ".fileprovider",
//                                photoFile);
//                        intent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);
//                        startActivityForResult(intent, 1);
//                    }
//                }
//            }
//        });
//
//    }

////    private File createImageFile() throws IOException {
////        // Create an image file name
////        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.CHINA).format(new Date());
////        String imageFileName = "JPEG_" + timeStamp + "_";
////        // getExternalFilesDir()方法可以获取到 SDCard/Android/data/你的应用的包名/files/ 目录，一般放一些长时间保存的数据
//////        File storageDir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
//////        Log.d("TAH", storageDir.toString());
////        //创建临时文件,文件前缀不能少于三个字符,后缀如果为空默认未".tmp"
////        File image = File.createTempFile(
////                imageFileName,  /* 前缀 */
////                ".jpg",         /* 后缀 */
////                storageDir      /* 文件夹 */
////        );
////        return image;
//    }


    // private void initTensorFlowAndLoadModel(Context context) {
        
    // }

    protected void fillBytes(final List<byte[]> byteList, final byte[][] yuvBytes) {
        // Because of the variable row stride it's not possible to know in
        // advance the actual necessary dimensions of the yuv planes.
        for (int i = 0; i < byteList.size(); ++i) {
          // final ByteBuffer buffer = byteList.get(i);
          if (yuvBytes[i] == null) {
            // LOGGER.d("Initializing buffer %d at size %d", i, buffer.capacity());
            // yuvBytes[i] = new byte[buffer.capacity()];
            yuvBytes[i] = byteList.get(i);
          }
          // buffer.get(yuvBytes[i]);
        }
      }

    private Bitmap scaleBitmap(Bitmap origin, int newWidth, int newHeight) {
        if (origin == null) {
            return null;
        }
        int height = origin.getHeight();
        int width = origin.getWidth();
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        Matrix matrix = new Matrix();
        matrix.postScale(scaleWidth, scaleHeight);
        // matrix.postRotate(90);
        Bitmap newBM = Bitmap.createBitmap(origin, 0, 0, width, height, matrix, false);
        if (!origin.isRecycled()) {
            origin.recycle();
        }
        return newBM;
    }

    public void realtimeTransfer(Context context, int yRowStride, int uvRowStride, int uvPixelStride, List<byte[]> byteList, int imgHeight, int imgWidth, int number) throws IOException {
      switch (number) {
        case 0:
            modelFile = "file:///android_asset/optimizedstyle_graph_0.pb";
          break;
        case 1:
            modelFile = "file:///android_asset/optimizedstyle_graph_1.pb";
          break;
        case 2:
            modelFile = "file:///android_asset/optimizedstyle_graph_2.pb";
          break;
        case 3:
            modelFile = "file:///android_asset/optimizedstyle_graph_3.pb";
          break;
        case 4:
            modelFile = "file:///android_asset/optimizedstyle_graph_4.pb";
          break;
        case 5:
            modelFile = "file:///android_asset/optimizedstyle_graph_5.pb";
          break;
        case 6:
            modelFile = "file:///android_asset/optimizedstyle_graph_6.pb";
          break;
        case 7:
            modelFile = "file:///android_asset/optimizedstyle_graph_7.pb";
          break;
        case 8:
            modelFile = "file:///android_asset/optimizedstyle_graph_8.pb";
          break;
        case 9:
            modelFile = "file:///android_asset/optimizedstyle_graph_9.pb";
          break;
        case 10:
            modelFile = "file:///android_asset/optimizedstyle_graph_10.pb";
          break;
        case 11:
            modelFile = "file:///android_asset/optimizedstyle_graph_11.pb";
          break;
      }

      inferenceInterface = new TensorFlowInferenceInterface(context.getAssets(), modelFile);
        intValues = new int[1 * 512 * 512];
        floatValues = new float[1 * 512 * 512 * 3];

        rgbBytes = new int[imgWidth * imgHeight];
        yuvBytes = new byte[3][];
        Matrix frameToCropTransform =
            ImageUtils.getTransformationMatrix(
                imgWidth, imgHeight,
                512, 512,
                0, true);

        Matrix cropToFrameTransform = new Matrix();
        frameToCropTransform.invert(cropToFrameTransform);
        // Plane[] planesArray = new Plane[planes.size()];
        // planes.toArray(planesArray);
        fillBytes(byteList, yuvBytes);

        // final int yRowStride = planesArray[0].getRowStride();
        // final int uvRowStride = planesArray[1].getRowStride();
        // final int uvPixelStride = planesArray[1].getPixelStride();

        ImageUtils.convertYUV420ToARGB8888(
          yuvBytes[0],
          yuvBytes[1],
          yuvBytes[2],
          imgWidth,
          imgHeight,
          yRowStride,
          uvRowStride,
          uvPixelStride,
          rgbBytes
      );
        rgbFrameBitmap = Bitmap.createBitmap(imgWidth, imgHeight, Config.ARGB_8888);
        rgbFrameBitmap.setPixels(rgbBytes, 0, imgWidth, 0, 0, imgWidth, imgHeight);
        // scale to square
        Bitmap croppedBitmap = Bitmap.createScaledBitmap(rgbFrameBitmap, 512, 512, false);
        // croppedBitmap = Bitmap.createBitmap(512, 512, Config.ARGB_8888);
        
        final Canvas canvas = new Canvas(croppedBitmap);
        canvas.drawBitmap(croppedBitmap, frameToCropTransform, null);

        // scale to square
        Bitmap scaledBitmap = Bitmap.createScaledBitmap(croppedBitmap, 512, 512, false);

        // Bitmap scaledBitmap = scaleBitmap(bitmap, 512, 512); // desiredSize
        scaledBitmap.getPixels(intValues, 0, scaledBitmap.getWidth(), 0, 0,
                scaledBitmap.getWidth(), scaledBitmap.getHeight());
        for (int i = 0; i < intValues.length; ++i) {
            final int val = intValues[i];
            floatValues[i * 3] = ((val >> 16) & 0xFF) * 1.0f;
            floatValues[i * 3 + 1] = ((val >> 8) & 0xFF) * 1.0f;
            floatValues[i * 3 + 2] = (val & 0xFF) * 1.0f;
        }

        // Copy the input data into TensorFlow.
        inferenceInterface.feed(INPUT_NODE, floatValues, 1, scaledBitmap.getWidth(), scaledBitmap.getHeight(), 3);
        // Run the inference call.
        inferenceInterface.run(new String[]{OUTPUT_NODE}, false);
        // Copy the output Tensor back into the output array.
        inferenceInterface.fetch(OUTPUT_NODE, floatValues);
        // Void[] sorted = Arrays.sort(floatValues);
        // float minvalue = sorted[0];
        // float maxvalue = sorted[sorted.length-1];
        // for (int i = 0; i < floatValues.length; i++){
        //     floatValues[i] = (floatValues[i] + minvalue) * (maxvalue - minvalue);
        //     floatValues[i] = floatValues[i] * 255;
        // }

        // Normalize the output before turn into integer, otherwise it will have some fake pixels.
        float r_max = 0, g_max = 0, b_max = 0, r_min = 999, g_min = 999, b_min = 999;
        for (int i = 0; i < intValues.length; ++i) {
            if (floatValues[i * 3] > r_max) {
                r_max = floatValues[i * 3];
            }
            if (floatValues[i * 3] < r_min) {
                r_min = floatValues[i * 3];
            }
            if (floatValues[i * 3 + 1] > g_max) {
                g_max = floatValues[i * 3 + 1];
            }
            if (floatValues[i * 3 + 1] < g_min) {
                g_min = floatValues[i * 3 + 1];
            }
            if (floatValues[i * 3 + 2] > b_max) {
                b_max = floatValues[i * 3 + 2];
            }
            if (floatValues[i * 3 + 2] < b_min) {
                b_min = floatValues[i * 3 + 2];
            }
        }

        for (int i = 0; i < intValues.length; ++i) {
            floatValues[i * 3] = (floatValues[i * 3] - r_min) / (r_max - r_min) * 255;
            floatValues[i * 3 + 1] = (floatValues[i * 3 + 1] - g_min) / (g_max - g_min) * 255;
            floatValues[i * 3 + 2] = (floatValues[i * 3 + 2] - b_min) / (b_max - b_min) * 255;
        }

        for (int i = 0; i < intValues.length; ++i) {
            intValues[i] =
                    0xFF000000
                            | (((int) (floatValues[i * 3 ])) << 16)
                            | (((int) (floatValues[i * 3 + 1])) << 8)
                            | ((int) (floatValues[i * 3 + 2]));
        }

        scaledBitmap.setPixels(intValues, 0, scaledBitmap.getWidth(), 0, 0,
                scaledBitmap.getWidth(), scaledBitmap.getHeight());

        //scale back
        scaledBitmap = Bitmap.createScaledBitmap(scaledBitmap, bitmap.getWidth(), bitmap.getHeight(), false);

        // runInBackground(
        // new Runnable() {
        //   @Override
        //   public void run() {
        //     Bitmap cropCopyBitmap = Bitmap.createBitmap(croppedBitmap);

        //     // final long startTime = SystemClock.uptimeMillis();
        //     stylizeImage(croppedBitmap);
        //     // lastProcessingTimeMs = SystemClock.uptimeMillis() - startTime;

        //     Bitmap textureCopyBitmap = Bitmap.createBitmap(croppedBitmap);

        //     // requestRender();
        //     // computing = false;
        //   }
        // });
    }

    public String styleTransfer(Context context, String inputFilePath, String outputDir, int number) {
        // initTensorFlowAndLoadModel(context);
        // if(number == 0){
        //     modelFile = "file:///android_asset/style_graph_5.pb";
        // }
        // if(number == 1){
        //     modelFile = "file:///android_asset/style_graph_6.pb";
        // }
        // if(number == 2){
        //     modelFile = "file:///android_asset/style_graph_7.pb";
        // }

        switch (number) {
            case 0:
                modelFile = "file:///android_asset/optimizedstyle_graph_0.pb";
              break;
            case 1:
                modelFile = "file:///android_asset/optimizedstyle_graph_1.pb";
              break;
            case 2:
                modelFile = "file:///android_asset/optimizedstyle_graph_2.pb";
              break;
            case 3:
                modelFile = "file:///android_asset/optimizedstyle_graph_3.pb";
              break;
            case 4:
                modelFile = "file:///android_asset/optimizedstyle_graph_4.pb";
              break;
            case 5:
                modelFile = "file:///android_asset/optimizedstyle_graph_5.pb";
              break;
            case 6:
                modelFile = "file:///android_asset/optimizedstyle_graph_6.pb";
              break;
            case 7:
                modelFile = "file:///android_asset/optimizedstyle_graph_7.pb";
              break;
            case 8:
                modelFile = "file:///android_asset/optimizedstyle_graph_8.pb";
              break;
            case 9:
                modelFile = "file:///android_asset/optimizedstyle_graph_9.pb";
              break;
            case 10:
                modelFile = "file:///android_asset/optimizedstyle_graph_10.pb";
              break;
            case 11:
                modelFile = "file:///android_asset/optimizedstyle_graph_11.pb";
              break;
          }

        inferenceInterface = new TensorFlowInferenceInterface(context.getAssets(), modelFile);
        intValues = new int[1 * 512 * 512];
        floatValues = new float[1 * 512 * 512 * 3];
        String outputFilePath = null;

        try{
            File file = new File(inputFilePath);
            FileInputStream fileInputStream = new FileInputStream(file);
            bitmap = BitmapFactory.decodeStream(fileInputStream);
        } catch (Exception e){
            bitmap = BitmapFactory.decodeFile(inputFilePath);
            e.printStackTrace();
        }

        // scale to square
        Bitmap scaledBitmap = Bitmap.createScaledBitmap(bitmap, 512, 512, false);

        // Bitmap scaledBitmap = scaleBitmap(bitmap, 512, 512); // desiredSize
        scaledBitmap.getPixels(intValues, 0, scaledBitmap.getWidth(), 0, 0,
                scaledBitmap.getWidth(), scaledBitmap.getHeight());
        for (int i = 0; i < intValues.length; ++i) {
            final int val = intValues[i];
            floatValues[i * 3] = ((val >> 16) & 0xFF) * 1.0f;
            floatValues[i * 3 + 1] = ((val >> 8) & 0xFF) * 1.0f;
            floatValues[i * 3 + 2] = (val & 0xFF) * 1.0f;
        }

        // Copy the input data into TensorFlow.
        inferenceInterface.feed(INPUT_NODE, floatValues, 1, scaledBitmap.getWidth(), scaledBitmap.getHeight(), 3);
        // Run the inference call.
        inferenceInterface.run(new String[]{OUTPUT_NODE}, false);
        // Copy the output Tensor back into the output array.
        inferenceInterface.fetch(OUTPUT_NODE, floatValues);
        // Void[] sorted = Arrays.sort(floatValues);
        // float minvalue = sorted[0];
        // float maxvalue = sorted[sorted.length-1];
        // for (int i = 0; i < floatValues.length; i++){
        //     floatValues[i] = (floatValues[i] + minvalue) * (maxvalue - minvalue);
        //     floatValues[i] = floatValues[i] * 255;
        // }

        // Normalize the output before turn into integer, otherwise it will have some fake pixels.
        float r_max = 0, g_max = 0, b_max = 0, r_min = 999, g_min = 999, b_min = 999;
        for (int i = 0; i < intValues.length; ++i) {
            if (floatValues[i * 3] > r_max) {
                r_max = floatValues[i * 3];
            }
            if (floatValues[i * 3] < r_min) {
                r_min = floatValues[i * 3];
            }
            if (floatValues[i * 3 + 1] > g_max) {
                g_max = floatValues[i * 3 + 1];
            }
            if (floatValues[i * 3 + 1] < g_min) {
                g_min = floatValues[i * 3 + 1];
            }
            if (floatValues[i * 3 + 2] > b_max) {
                b_max = floatValues[i * 3 + 2];
            }
            if (floatValues[i * 3 + 2] < b_min) {
                b_min = floatValues[i * 3 + 2];
            }
        }

        for (int i = 0; i < intValues.length; ++i) {
            floatValues[i * 3] = (floatValues[i * 3] - r_min) / (r_max - r_min) * 255;
            floatValues[i * 3 + 1] = (floatValues[i * 3 + 1] - g_min) / (g_max - g_min) * 255;
            floatValues[i * 3 + 2] = (floatValues[i * 3 + 2] - b_min) / (b_max - b_min) * 255;
        }

        for (int i = 0; i < intValues.length; ++i) {
            intValues[i] =
                    0xFF000000
                            | (((int) (floatValues[i * 3 ])) << 16)
                            | (((int) (floatValues[i * 3 + 1])) << 8)
                            | ((int) (floatValues[i * 3 + 2]));
        }

        String outputFileName = String.valueOf(System.currentTimeMillis()) + ".jpeg";
        File outputFile = new File(outputDir +"/" + outputFileName);
        if (outputFile.exists()) outputFile.delete();

        scaledBitmap.setPixels(intValues, 0, scaledBitmap.getWidth(), 0, 0,
                scaledBitmap.getWidth(), scaledBitmap.getHeight());

        //scale back
        scaledBitmap = Bitmap.createScaledBitmap(scaledBitmap, bitmap.getWidth(), bitmap.getHeight(), false);

        try {
            FileOutputStream out = new FileOutputStream(outputFile);
            scaledBitmap.compress(Bitmap.CompressFormat.JPEG, 100, out);
            out.flush();
            out.close();
            ExifInterface inputExif = new ExifInterface(inputFilePath);
            ExifInterface outputExif = new ExifInterface(outputFile.getAbsolutePath());
            Log.i("inputOri", String.valueOf(inputExif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_UNDEFINED)));
            outputExif.setAttribute(ExifInterface.TAG_ORIENTATION, inputExif.getAttribute(ExifInterface.TAG_ORIENTATION));
            outputExif.saveAttributes();
            outputFilePath = outputFile.getAbsolutePath();

            // free up memory
            scaledBitmap.recycle();
            scaledBitmap = null;
            bitmap.recycle();
            bitmap = null;
            floatValues = null;
            intValues = null;
            System.gc();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return outputFilePath;
//        return scaledBitmap;
    }

//    @Override
//    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
//        super.onActivityResult(requestCode, resultCode, data);
//        if (resultCode == RESULT_OK) {
//            if (requestCode == CODE) {
//                try {
//                    is = new FileInputStream(photoFile);
//                    Bitmap bitmap = BitmapFactory.decodeStream(is);
//                    Bitmap bitmap2 = stylizeImage(bitmap);
//                    ivPhoto.setImageBitmap(bitmap2);
//                } catch (FileNotFoundException e) {
//                    e.printStackTrace();
//                } finally {
//                    try {
//                        is.close();
//                    } catch (IOException e) {
//                        e.printStackTrace();
//                    }
//                }
//            }
//        }
//    }

}