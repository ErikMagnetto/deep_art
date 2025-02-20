/* Copyright 2015 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

package uet.deep_art;

import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.os.Environment;

import java.io.File;
import java.io.FileOutputStream;

/**
 * Utility class for manipulating images.
 **/
public class ImageUtils {
//  @SuppressWarnings("unused")
//  private static final Logger LOGGER = new Logger();
  
  static {
    try {
      System.loadLibrary("tensorflow_demo");
    } catch (UnsatisfiedLinkError e) {
//      LOGGER.w("Native library not found, native RGB -> YUV conversion may be unavailable.");
    }
  }

  /**
   * Utility method to compute the allocated size in bytes of a YUV420SP image
   * of the given dimensions.
   */
  public static int getYUVByteSize(final int width, final int height) {
    // The luminance plane requires 1 byte per pixel.
    final int ySize = width * height;

    // The UV plane works on 2x2 blocks, so dimensions with odd size must be rounded up.
    // Each 2x2 block takes 2 bytes to encode, one each for U and V.
    final int uvSize = ((width + 1) / 2) * ((height + 1) / 2) * 2;

    return ySize + uvSize;
  }

  /**
   * Saves a Bitmap object to disk for analysis.
   *
   * @param bitmap The bitmap to save.
   */
  public static void saveBitmap(final Bitmap bitmap) {
    saveBitmap(bitmap, "preview.png");
  }

  /**
   * Saves a Bitmap object to disk for analysis.
   *
   * @param bitmap The bitmap to save.
   * @param filename The location to save the bitmap to.
   */
  public static void saveBitmap(final Bitmap bitmap, final String filename) {
    final String root =
        Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + "tensorflow";
//    LOGGER.i("Saving %dx%d bitmap to %s.", bitmap.getWidth(), bitmap.getHeight(), root);
    final File myDir = new File(root);

    if (!myDir.mkdirs()) {
//      LOGGER.i("Make dir failed");
    }

    final String fname = filename;
    final File file = new File(myDir, fname);
    if (file.exists()) {
      file.delete();
    }
    try {
      final FileOutputStream out = new FileOutputStream(file);
      bitmap.compress(Bitmap.CompressFormat.PNG, 99, out);
      out.flush();
      out.close();
    } catch (final Exception e) {
//      LOGGER.e(e, "Exception!");
    }
  }

  // This value is 2 ^ 18 - 1, and is used to clamp the RGB values before their ranges
  // are normalized to eight bits.
  static final int kMaxChannelValue = 262143;

  // Always prefer the native implementation if available.
  private static boolean useNativeConversion = false;

  public static void convertYUV420ToARGB8888(
      byte[] yData,
      byte[] uData,
      byte[] vData,
      int width,
      int height,
      int yRowStride,
      int uvRowStride,
      int uvPixelStride,
      int[] out) {
    if (useNativeConversion) {
      try {
        convertYUV420ToARGB8888(
            yData, uData, vData, out, width, height, yRowStride, uvRowStride, uvPixelStride, false);
        return;
      } catch (UnsatisfiedLinkError e) {
//        LOGGER.w("Native YUV -> RGB implementation not found, falling back to Java implementation");
        useNativeConversion = false;
      }
    }

    int i = 0;
    for (int y = 0; y < height; y++) {
      int pY = yRowStride * y;
      int uv_row_start = uvRowStride * (y >> 1);
      int pUV = uv_row_start;
      int pV = uv_row_start;

      for (int x = 0; x < width; x++) {
        int uv_offset = pUV + (x >> 1) * uvPixelStride;
        out[i++] =
            YUV2RGB(
                convertByteToInt(yData, pY + x),
                convertByteToInt(uData, uv_offset),
                convertByteToInt(vData, uv_offset));
      }
    }
  }

  private static int convertByteToInt(byte[] arr, int pos) {
    return arr[pos] & 0xFF;
  }

  private static int YUV2RGB(int nY, int nU, int nV) {
    nY -= 16;
    nU -= 128;
    nV -= 128;
    if (nY < 0) nY = 0;

    // This is the floating point equivalent. We do the conversion in integer
    // because some Android devices do not have floating point in hardware.
    // nR = (int)(1.164 * nY + 2.018 * nU);
    // nG = (int)(1.164 * nY - 0.813 * nV - 0.391 * nU);
    // nB = (int)(1.164 * nY + 1.596 * nV);

    final int foo = 1192 * nY;
    int nR = foo + 1634 * nV;
    int nG = foo - 833 * nV - 400 * nU;
    int nB = foo + 2066 * nU;

    nR = Math.min(kMaxChannelValue, Math.max(0, nR));
    nG = Math.min(kMaxChannelValue, Math.max(0, nG));
    nB = Math.min(kMaxChannelValue, Math.max(0, nB));

    return 0xff000000 | ((nR << 6) & 0x00ff0000) | ((nG >> 2) & 0x0000FF00) | ((nB >> 10) & 0xff);
  }

  /**
   * Converts YUV420 semi-planar data to ARGB 8888 data using the supplied width and height. The
   * input and output must already be allocated and non-null. For efficiency, no error checking is
   * performed.
   *
   * @param input The array of YUV 4:2:0 input data.
   * @param output A pre-allocated array for the ARGB 8:8:8:8 output data.
   * @param width The width of the input image.
   * @param height The height of the input image.
   * @param halfSize If true, downsample to 50% in each dimension, otherwise not.
   */
  public static native void convertYUV420SPToARGB8888(
      byte[] input, int[] output, int width, int height, boolean halfSize);

  /**
   * Converts YUV420 semi-planar data to ARGB 8888 data using the supplied width
   * and height. The input and output must already be allocated and non-null.
   * For efficiency, no error checking is performed.
   *
   * @param y
   * @param u
   * @param v
   * @param uvPixelStride
   * @param width The width of the input image.
   * @param height The height of the input image.
   * @param halfSize If true, downsample to 50% in each dimension, otherwise not.
   * @param output A pre-allocated array for the ARGB 8:8:8:8 output data.
   */
  public static native void convertYUV420ToARGB8888(
      byte[] y,
      byte[] u,
      byte[] v,
      int[] output,
      int width,
      int height,
      int yRowStride,
      int uvRowStride,
      int uvPixelStride,
      boolean halfSize);

  /**
   * Converts YUV420 semi-planar data to RGB 565 data using the supplied width
   * and height. The input and output must already be allocated and non-null.
   * For efficiency, no error checking is performed.
   *
   * @param input The array of YUV 4:2:0 input data.
   * @param output A pre-allocated array for the RGB 5:6:5 output data.
   * @param width The width of the input image.
   * @param height The height of the input image.
   */
  public static native void convertYUV420SPToRGB565(
      byte[] input, byte[] output, int width, int height);

  /**
   * Converts 32-bit ARGB8888 image data to YUV420SP data.  This is useful, for
   * instance, in creating data to feed the classes that rely on raw camera
   * preview frames.
   *
   * @param input An array of input pixels in ARGB8888 format.
   * @param output A pre-allocated array for the YUV420SP output data.
   * @param width The width of the input image.
   * @param height The height of the input image.
   */
  public static native void convertARGB8888ToYUV420SP(
      int[] input, byte[] output, int width, int height);

  /**
   * Converts 16-bit RGB565 image data to YUV420SP data.  This is useful, for
   * instance, in creating data to feed the classes that rely on raw camera
   * preview frames.
   *
   * @param input An array of input pixels in RGB565 format.
   * @param output A pre-allocated array for the YUV420SP output data.
   * @param width The width of the input image.
   * @param height The height of the input image.
   */
  public static native void convertRGB565ToYUV420SP(
      byte[] input, byte[] output, int width, int height);

  /**
   * Returns a transformation matrix from one reference frame into another.
   * Handles cropping (if maintaining aspect ratio is desired) and rotation.
   *
   * @param srcWidth Width of source frame.
   * @param srcHeight Height of source frame.
   * @param dstWidth Width of destination frame.
   * @param dstHeight Height of destination frame.
   * @param applyRotation Amount of rotation to apply from one frame to another.
   *  Must be a multiple of 90.
   * @param maintainAspectRatio If true, will ensure that scaling in x and y remains constant,
   * cropping the image if necessary.
   * @return The transformation fulfilling the desired requirements.
   */
  public static Matrix getTransformationMatrix(
      final int srcWidth,
      final int srcHeight,
      final int dstWidth,
      final int dstHeight,
      final int applyRotation,
      final boolean maintainAspectRatio) {
    final Matrix matrix = new Matrix();

    if (applyRotation != 0) {
      // Translate so center of image is at origin.
      matrix.postTranslate(-srcWidth / 2.0f, -srcHeight / 2.0f);

      // Rotate around origin.
      matrix.postRotate(applyRotation);
    }

    // Account for the already applied rotation, if any, and then determine how
    // much scaling is needed for each axis.
    final boolean transpose = (Math.abs(applyRotation) + 90) % 180 == 0;

    final int inWidth = transpose ? srcHeight : srcWidth;
    final int inHeight = transpose ? srcWidth : srcHeight;

    // Apply scaling if necessary.
    if (inWidth != dstWidth || inHeight != dstHeight) {
      final float scaleFactorX = dstWidth / (float) inWidth;
      final float scaleFactorY = dstHeight / (float) inHeight;

      if (maintainAspectRatio) {
        // Scale by minimum factor so that dst is filled completely while
        // maintaining the aspect ratio. Some image may fall off the edge.
        final float scaleFactor = Math.max(scaleFactorX, scaleFactorY);
        matrix.postScale(scaleFactor, scaleFactor);
      } else {
        // Scale exactly to fill dst from src.
        matrix.postScale(scaleFactorX, scaleFactorY);
      }
    }

    if (applyRotation != 0) {
      // Translate back from origin centered reference to destination frame.
      matrix.postTranslate(dstWidth / 2.0f, dstHeight / 2.0f);
    }

    return matrix;
  }
}
