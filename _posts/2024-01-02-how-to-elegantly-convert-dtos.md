---
categories: [编程语言, Java]
date: 2024-01-02 13:03:00 +0800
last_modified_at: 2024-01-02 19:53:00 +0800
tags:
- Spring Boot
- Spring Data JPA
- H2
- DTO
title: 如何优雅的转换 DTO 对象？
---

在 Java 编程中，DTO（Data Transfer Object）对象通常用于在不同层之间传输数据。DTO 是一个纯数据对象，它主要用于封装应用程序中的数据，以便在不同部分之间传递。

本文示例工程基于 Spring Boot、Spring Data JPA 和 H2 数据库搭建。

## 1.场景描述

出于演示目的，我们仅考虑简单的用户数据，在 OA 系统中，当系统管理员添加用户时，仅需传入姓名、年龄和手机号，后端接收到数据后，将生成用户的唯一标识 `id`，然后持久化到数据库，当编辑用户信息时，后端根据传入的唯一标识 `id` 完成用户信息的修改。

```java
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public ResponseEntity<User> createUser(User newUser) {
        User user = userService.createUser(newUser);
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, User updatedUser) {
        updatedUser.setId(id);
        User user = userService.updateUser(updatedUser);
        return ResponseEntity.ok(user);
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(@PathVariable Long id) {
        User user = userService.getUser(id);
        return ResponseEntity.ok(user);
    }

}
```

以上是 OA 系统中，新增、更新和查询用户的一段示例代码，可以看到，传入的参数对象和返回的响应对象直接使用的数据库实体对象。

这样设计有两点问题，一是对外暴露了数据库实体，导致表结构和敏感字段泄露；二是增加了不必要网络开销，如实体类属性较多，而仅需返回少部分属性字段的情况。

## 2.优化步骤

### 2.1.引入 DTO

为了解决上面的两个问题，我们引入 DTO 和 VO 的设计。分别新增 `NewUser` 和 `UpdatedUser` DTO 对象：
> 本文主要是讨论 DTO 的设计，VO 的设计不做探讨。
{: .prompt-tip }

```java
@Data
public class NewUser implements Serializable {
    
    private String name;

    private Integer age;

    private String phoneNumber;

}
```

```java
@Data
public class UpdatedUser implements Serializable {
    
    private String name;

    private Integer age;

    private String phoneNumber;

}
```

优化后的 `UserController` 类如下：

```java
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public ResponseEntity<UserVo> createUser(@RequestBody NewUser newUser) {
        User user = new User();
        user.setName(newUser.getName());
        user.setAge(newUser.getAge());
        user.setPhoneNumber(newUser.getPhoneNumber());

        User result = userService.createUser(user);

        UserVo userVo = new UserVo();
        userVo.setId(result.getId());
        userVo.setName(result.getName());
        userVo.setAge(result.getAge());
        userVo.setPhoneNumber(result.getPhoneNumber());

        return ResponseEntity.ok(userVo);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserVo> updateUser(@PathVariable Long id, @RequestBody UpdatedUser updatedUser) {
        User user = new User();
        user.setId(id);
        user.setName(updatedUser.getName());
        user.setAge(updatedUser.getAge());
        user.setPhoneNumber(updatedUser.getPhoneNumber());

        User result = userService.updateUser(user);

        UserVo userVo = new UserVo();
        userVo.setId(result.getId());
        userVo.setName(result.getName());
        userVo.setAge(result.getAge());
        userVo.setPhoneNumber(result.getPhoneNumber());

        return ResponseEntity.ok(userVo);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserVo> getUser(@PathVariable Long id) {
        User result = userService.getUser(id);

        UserVo userVo = new UserVo();
        userVo.setId(result.getId());
        userVo.setName(result.getName());
        userVo.setAge(result.getAge());
        userVo.setPhoneNumber(result.getPhoneNumber());

        return ResponseEntity.ok(userVo);
    }

}
```

### 2.2.引入工具类来优化

当前只有 4 个属性，当属性很多的时候，我们就需要引入工具类来优化代码，优化后的代码如下：

```java
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public ResponseEntity<UserVo> createUser(@RequestBody NewUser newUser) {
        User user = new User();
        BeanUtils.copyProperties(newUser, user);

        User result = userService.createUser(user);

        UserVo userVo = new UserVo();
        BeanUtils.copyProperties(result, userVo);

        return ResponseEntity.ok(userVo);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserVo> updateUser(@PathVariable Long id, @RequestBody UpdatedUser updatedUser) {
        User user = new User();
        BeanUtils.copyProperties(updatedUser, user);
        user.setId(id);

        User result = userService.updateUser(user);

        UserVo userVo = new UserVo();
        BeanUtils.copyProperties(result, userVo);

        return ResponseEntity.ok(userVo);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserVo> getUser(@PathVariable Long id) {
        User result = userService.getUser(id);

        UserVo userVo = new UserVo();
        BeanUtils.copyProperties(result, userVo);

        return ResponseEntity.ok(userVo);
    }

}
```

> `BeanUtils.copyProperties()` 是一个浅拷贝的方法，它将名称和类型一致的属性拷贝到目标对象。
{: .prompt-tip }

### 2.3.封装转换过程

上一步引入工具类简化了代码，但为了语义上的统一，使用相同层次的语义操作，不暴露具体实现，封装后的代码如下：

```java
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public ResponseEntity<UserVo> createUser(@RequestBody NewUser newUser) {
        User user = convertFor(newUser);
        User result = userService.createUser(user);
        UserVo userVo = convertFor(result);
        return ResponseEntity.ok(userVo);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserVo> updateUser(@PathVariable Long id, @RequestBody UpdatedUser updatedUser) {
        User user = convertFor(updatedUser)
            .setId(id);
        User result = userService.updateUser(user);
        UserVo userVo = convertFor(result);
        return ResponseEntity.ok(userVo);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserVo> getUser(@PathVariable Long id) {
        User result = userService.getUser(id);
        UserVo userVo = convertFor(result);
        return ResponseEntity.ok(userVo);
    }

    private User convertFor(NewUser newUser) {
        User user = new User();
        BeanUtils.copyProperties(newUser, user);
        return user;
    }

    private UserVo convertFor(User user) {
        UserVo userVo = new UserVo();
        BeanUtils.copyProperties(user, userVo);
        return userVo;
    }

    private User convertFor(UpdatedUser updatedUser) {
        User user = new User();
        BeanUtils.copyProperties(updatedUser, user);
        return user;
    }
}
```

### 2.4.提取为抽象接口

在实际的编码中，DTO 的转换操作有很多，考虑到其通用性，我们将其抽象为接口：

```java
public interface DtoConvert<S, T> {

    T convert(S s);

}
```

然后，分别添加 `NewUserConvert`、`UpdatedUserConvert`和 `UserConvert` 类，并实现 convert 方法：

```java
public class NewUserConvert implements DtoConvert<NewUser, User> {

    @Override
    public User convert(NewUser newUser) {
        User user = new User();
        BeanUtils.copyProperties(newUser, user);
        return user;
    }

}
```

`UpdatedUserConvert`和 `UserConvert` 类 `convert` 方法实现和 `NewUserConvert` 类 `convert` 方法一致，出于篇幅考虑，本文不再赘述，优化后的 `UserController` 代码如下：

```java
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public ResponseEntity<UserVo> createUser(@RequestBody NewUser newUser) {
        User user = new NewUserConvert().convert(newUser);
        User result = userService.createUser(user);
        UserVo userVo = new UserConvert().convert(result);
        return ResponseEntity.ok(userVo);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserVo> updateUser(@PathVariable Long id, @RequestBody UpdatedUser updatedUser) {
        User user = new UpdatedUserConvert().convert(updatedUser)
                .setId(id);
        User result = userService.updateUser(user);
        UserVo userVo = new UserConvert().convert(result);
        return ResponseEntity.ok(userVo);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserVo> getUser(@PathVariable Long id) {
        User result = userService.getUser(id);
        UserVo userVo = new UserConvert().convert(result);
        return ResponseEntity.ok(userVo);
    }
}
```

### 2.5.使用聚合进一步优化

对于 DTO 对象，每一次都需要 new 一个新的转换器进行转换，显然使用起来不太方便，所以，考虑将转换器类和 DTO 类进行聚合，聚合后的 `NewUser` 类如下：

```java
@Data
public class NewUser implements Serializable {
    
    private String name;

    private Integer age;

    private String phoneNumber;

    public User convertToUser() {
        return new NewUserConvert()
                .convert(this);
    }

    private static class NewUserConvert implements DtoConvert<NewUser, User> {

        @Override
        public User convert(NewUser newUser) {
            User user = new User();
            BeanUtils.copyProperties(newUser, user);
            return user;
        }

    }

}
```

`UpdatedUser` 和 `User` 类和上面的实现方式一致，本文不再赘述，优化后的 `UserController` 代码如下：

```java
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    public ResponseEntity<UserVo> createUser(@RequestBody NewUser newUser) {
        User user = newUser.convertToUser();
        UserVo userVo = userService.createUser(user).convertToUserVo();
        return ResponseEntity.ok(userVo);
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserVo> updateUser(@PathVariable Long id, @RequestBody UpdatedUser updatedUser) {
        User user = updatedUser.convertToUser().setId(id);
        UserVo userVo = userService.updateUser(user).convertToUserVo();
        return ResponseEntity.ok(userVo);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserVo> getUser(@PathVariable Long id) {
        UserVo userVo = userService.getUser(id).convertToUserVo();
        return ResponseEntity.ok(userVo);
    }
}
```

我们在 DTO 类和 Entity 类中添加转换的方法，这样可以将代码的可读性变得更强，且符合语义。

## 3.总结

DTO 对象的使用有助于降低耦合度，提高代码的可维护性，并在不同层次或组件之间提供清晰的数据传递机制。DTO 对象的使用场景如下：

1. 服务层和控制层之间传输数据
2. 在不同微服务之间传输数据
3. 在远程调用中传递数据

本文示例仓库地址：[https://github.com/harrisonwang/oa.git](https://github.com/harrisonwang/oa.git)