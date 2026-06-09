package util;

import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import javax.imageio.ImageIO;

public final class ImageSearchUtil {

    private static final int HASH_SIZE = 8;

    private ImageSearchUtil() {
    }

    public static long averageHash(byte[] imageData) throws IOException {
        if (imageData == null || imageData.length == 0) {
            throw new IOException("Empty image data");
        }

        BufferedImage source = ImageIO.read(new ByteArrayInputStream(imageData));
        if (source == null) {
            throw new IOException("Unsupported image format");
        }

        BufferedImage grayImage = new BufferedImage(HASH_SIZE, HASH_SIZE, BufferedImage.TYPE_BYTE_GRAY);
        Graphics2D graphics = grayImage.createGraphics();
        try {
            graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            graphics.drawImage(source, 0, 0, HASH_SIZE, HASH_SIZE, null);
        } finally {
            graphics.dispose();
        }

        int[] pixels = new int[HASH_SIZE * HASH_SIZE];
        grayImage.getRaster().getPixels(0, 0, HASH_SIZE, HASH_SIZE, pixels);

        long total = 0L;
        for (int pixel : pixels) {
            total += pixel & 0xFF;
        }

        int average = (int) (total / pixels.length);
        long hash = 0L;
        for (int pixel : pixels) {
            hash <<= 1;
            if ((pixel & 0xFF) >= average) {
                hash |= 1L;
            }
        }
        return hash;
    }

    public static int hammingDistance(long leftHash, long rightHash) {
        return Long.bitCount(leftHash ^ rightHash);
    }
}