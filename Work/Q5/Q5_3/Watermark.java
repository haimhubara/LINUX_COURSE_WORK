import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.*;
import javax.imageio.ImageIO;

public class Watermark {
    public static void main(String[] args) {
        if (args.length < 3) {
            System.out.println("Usage: java Watermark <folder_path> <student_name> <student_id>");
            return;
        }

        String folderPath = args[0];
        String studentName = args[1];
        String studentId = args[2];

        Path folder = Paths.get(folderPath);
        if (!Files.exists(folder) || !Files.isDirectory(folder)) {
            System.out.println("Invalid folder path");
            return;
        }

        try {
            Files.walk(folder) // Using Files.walk to find image files
                .filter(path -> path.toString().endsWith(".png") || path.toString().endsWith(".jpg"))
                .forEach(path -> processImage(path, studentName, studentId));
        } catch (IOException e) {
            System.out.println("Error reading directory: " + e.getMessage());
        }
    }

    private static void processImage(Path path, String studentName, String studentId) {
        try {
            BufferedImage image = ImageIO.read(path.toFile());
            if (image == null) {
                System.out.println("Error: Unable to read image from " + path);
                return;
            }

            // Add watermark
            Graphics2D g = image.createGraphics();
            g.setFont(new Font("Arial", Font.BOLD, 30));
            g.setColor(Color.BLACK);
            g.drawString("Student: " + studentName + " | ID: " + studentId, 20, image.getHeight() - 50);
            g.dispose();

            // Save watermarked image
            Path outputFile = Paths.get(path.getParent().toString(), "watermarked_" + path.getFileName().toString());
            ImageIO.write(image, "png", outputFile.toFile());
            System.out.println("Watermarked: " + path.getFileName());
        } catch (IOException e) {
            System.out.println("Error processing " + path.getFileName() + ": " + e.getMessage());
        }
    }
}
