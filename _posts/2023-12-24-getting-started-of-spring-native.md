---
categories: [编程语言, Java]
date: 2023-12-24 21:08:00 +0800
last_modified_at: 2023-12-24 21:10:00 +0800
tags:
- Spring Native
- Spring Boot
- MyBatis
title: Spring Native 快速上手
---
Spring Native 是一种将 Spring 应用编译为本机可执行文件的技术，无需 Java 虚拟机 (JVM)。这使得 Spring 应用可以实现毫秒级的启动时间、更低的内存占用、更高的性能、更强的安全性以及更易于部署。

Spring Native 通过字节码生成和提前编译技术将 Spring 应用编译为本机可执行文件。字节码生成技术将 Java 字节码转换为本机机器码，而提前编译技术则在编译时而不是在运行时执行某些计算。这使得 Spring Native 应用可以绕过 JVM 的解释和运行过程，直接运行编译后的机器码，从而获得更好的性能。

Spring Native 适用于各种类型的 Spring 应用，包括 Web 应用、微服务、批处理应用和命令行工具。它还支持与各种框架和库集成，包括 MyBatis、Spring Data 和 Spring Security。

本文使用 Spring initializr 快速创建了一个集成 MyBatis 和 Spring Native 的 Spring Boot 应用程序。

## 前提条件

需要安装 [GraalVM](https://github.com/graalvm/graalvm-ce-builds/releases) 并需要定义以下环境变量：

- JAVA_HOME
- GraalVM_HOME

## 操作步骤

### 1.创建项目

使用以下命令创建一个带有 MyBatis 和 H2 数据库的 Spring Boot 应用程序。

```bash
$ curl -s https://start.spring.io/starter.tgz\
     -d name=mybatis-sample\
     -d artifactId=mybatis-sample\
     -d dependencies=mybatis,h2,native\
     -d baseDir=mybatis-sample\
     | tar -xzvf - && cd mybatis-sample
```

### 2.添加 mybatis-spring-native 依赖

打开 pom.xml 文件并添加 mybatis-spring-native 依赖配置。

```xml
<dependency>
  <groupId>org.mybatis.spring.native</groupId>
  <artifactId>mybatis-spring-native-core</artifactId>
  <version>0.1.0-SNAPSHOT</version>
</dependency>
```

如果你使用 SNAPSHOT 版本，请添加 Sonatype OSS 快照存储库，如下所示：

```xml
<repository>
  <id>sonatype-oss-snapshots</id>
  <name>Sonatype OSS Snapshots Repository</name>
  <url>https://oss.sonatype.org/content/repositories/snapshots</url>
</repository>
```

### 3.新建 SQL 脚本

新建一个 sql 脚本（`src/main/resources/schema.sql`）来生成 city 表。

```sql
CREATE TABLE city
(
  id      INT PRIMARY KEY auto_increment,
  name    VARCHAR,
  state   VARCHAR,
  country VARCHAR
);
```

### 4.新建 domain 类

新建 `City` 类（`src/main/java/com/example/mybatissample/City.java`)。

```java
package com.example.mybatissample;

public class City {

  private Long id;
  private String name;
  private String state;
  private String country;

  public Long getId() {
    return this.id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getName() {
    return this.name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getState() {
    return this.state;
  }

  public void setState(String state) {
    this.state = state;
  }

  public String getCountry() {
    return this.country;
  }

  public void setCountry(String country) {
    this.country = country;
  }

  @Override
  public String toString() {
    return getId() + "," + getName() + "," + getState() + "," + getCountry();
  }

}
```

### 5.新建 mapper 接口

创建 `com.example.mybatissample.CityMapper` 接口类，通过注解驱动。

```java
package com.example.mybatissample;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface CityMapper {

  @Insert("INSERT INTO city (name, state, country) VALUES(#{name}, #{state}, #{country})")
  @Options(useGeneratedKeys = true, keyProperty = "id")
  void insert(City city);

  @Select("SELECT id, name, state, country FROM city WHERE id = #{id}")
  City findById(long id);

}
```

### 6.修改 Spring Boot 应用启动类

添加 `CommandLineRunner`实现，调用 `CityMapper` 实现添加城市

```java
package com.example.mybatissample;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class MybatisSampleApplication {

  public static void main(String[] args) {
    SpringApplication.run(MybatisSampleApplication.class, args);
  }

  private final CityMapper cityMapper;

  public MybatisSampleApplication(CityMapper cityMapper) {
    this.cityMapper = cityMapper;
  }

  @Bean
  CommandLineRunner sampleCommandLineRunner() {
    return args -> {
      City city = new City();
      city.setName("San Francisco");
      city.setState("CA");
      city.setCountry("US");
      cityMapper.insert(city);
      System.out.println(this.cityMapper.findById(city.getId()));
    };
  }

}
```

### 7.运行 Spring Boot 应用

使用 Spring Boot Maven 插件运行创建的应用程序，本文使用 `spring-boot:run` 命令启动应用

```bash
E:\tmp\mybatis-sample>mvn spring-boot:run
```

启动成功后的日志如下：

```
2022-02-10 16:29:41.362  INFO 11824 --- [           main] o.s.nativex.NativeListener               : AOT mode disabled

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v2.6.3)

2022-02-10 16:29:41.423  INFO 11824 --- [           main] c.e.m.MybatisSampleApplication           : Starting MybatisSampleApplication using Java 17.0.2 on LAPTOP-Xiaowangye with PID 11824 (E:\tmp\mybatis-sample\target\classes started by Xiaowangye in E:\tmp\mybatis-sample)
2022-02-10 16:29:41.423  INFO 11824 --- [           main] c.e.m.MybatisSampleApplication           : No active profile set, falling back to default profiles: default
2022-02-10 16:29:42.078  INFO 11824 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2022-02-10 16:29:42.204  INFO 11824 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2022-02-10 16:29:42.279  INFO 11824 --- [           main] c.e.m.MybatisSampleApplication           : Started MybatisSampleApplication in 1.156 seconds (JVM running for 1.412)
1,San Francisco,CA,US
2022-02-10 16:29:42.319  INFO 11824 --- [ionShutdownHook] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2022-02-10 16:29:42.322  INFO 11824 --- [ionShutdownHook] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  3.091 s
[INFO] Finished at: 2022-02-10T16:29:42+08:00
[INFO] ------------------------------------------------------------------------
```

### 8.生成本地可执行文件和可执行 jar

通过以下方式打包本地可执行文件和 jar 文件：

```bash
E:\tmp\mybatis-sample>mvn package -Pnative -DskipTests
```

> 注意：Windows 平台请使用 x64 Native Tools Command Prompt 命令提示符执行
{: .prompt-tip }

运行 Native Image：

```
E:\tmp\mybatis-sample>target\mybatis-sample
```

```
2022-02-10 15:55:07.745  INFO 13576 --- [           main] o.s.nativex.NativeListener               : AOT mode enabled

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v2.6.3)

2022-02-10 15:55:07.755  INFO 13576 --- [           main] c.e.m.MybatisSampleApplication           : Starting MybatisSampleApplication v0.0.1-SNAPSHOT using Java 17.0.2 on LAPTOP-Xiaowangye with PID 13576 (E:\tmp\mybatis-sample\target\mybatis-sample.exe started by Xiaowangye in E:\tmp\mybatis-sample)
2022-02-10 15:55:07.755  INFO 13576 --- [           main] c.e.m.MybatisSampleApplication           : No active profile set, falling back to default profiles: default
2022-02-10 15:55:07.813  INFO 13576 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2022-02-10 15:55:07.816  INFO 13576 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2022-02-10 15:55:07.823  INFO 13576 --- [           main] c.e.m.MybatisSampleApplication           : Started MybatisSampleApplication in 0.098 seconds (JVM running for 0.1)
1,San Francisco,CA,US
2022-02-10 15:55:07.825  INFO 13576 --- [ionShutdownHook] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2022-02-10 15:55:07.826  INFO 13576 --- [ionShutdownHook] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.
```

## 总结

Spring Native 是一种非常有前景的技术，它可以帮助 Spring 应用在性能、启动时间、内存占用、安全性以及部署方面获得显著的提升。