package com.checklist.util;

import javax.servlet.ServletContext;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;

public class AppFilePaths {
    public static Path dataDir(ServletContext context) {
        String real = context.getRealPath("/WEB-INF/data");
        if (real != null) {
            return Paths.get(real);
        }
        return Paths.get(System.getProperty("java.io.tmpdir"), "checklist-app", "data");
    }

    public static Path templatesFile(ServletContext context) {
        return dataDir(context).resolve("templates.json");
    }

    public static Path resultFileByYear(ServletContext context, int year) {
        return dataDir(context).resolve("results").resolve("results_" + year + ".json");
    }

    public static File uploadDir(ServletContext context, String type) {
        String real = context.getRealPath("/uploads/" + type);
        if (real != null) {
            return new File(real);
        }
        return new File(System.getProperty("java.io.tmpdir"), "checklist-app/uploads/" + type);
    }
}
