package cn.keking.web.controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

/**
 *  页面跳转
 * @author yudian-it
 * @date 2017/12/27
 */
@Controller
public class IndexController {

    @GetMapping( "/index")
    public String go2Index(){
        return "/main/index";
    }

    @GetMapping( "/record")
    public String go2Record(){
        return "/main/record";
    }

    @GetMapping( "/sponsor")
    public String go2Sponsor(){
        return "/main/sponsor";
    }

    @GetMapping( "/integrated")
    public String go2Integrated(){
        return "/main/integrated";
    }

    @GetMapping( "/")
    public String root() {
        return "/main/index";
    }

    @GetMapping("/L6t1iigOAM")
    public @ResponseBody String serveTextFile() throws IOException {
        // 从 resources/static/ 下读取文件
        ClassPathResource resource = new ClassPathResource("static/L6t1iigOAM.txt");

        // 使用 InputStream + BufferedReader 读取文件内容（兼容 Java 8）
        try (InputStream is = resource.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {

            StringBuilder content = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }

            return content.toString();
        }
    }

}
