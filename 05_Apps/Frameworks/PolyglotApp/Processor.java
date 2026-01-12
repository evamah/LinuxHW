import java.util.Scanner;
public class Processor {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        while(scanner.hasNextInt()) {
            int num = scanner.nextInt();
            System.out.println(num * 10);
        }
    }
}
