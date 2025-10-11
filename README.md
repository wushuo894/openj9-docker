# OpenJ9 Docker 镜像

这是一个基于 IBM Semeru OpenJ9 的轻量级 Docker 镜像项目，使用多阶段构建技术创建了一个优化的 Java 运行环境。

## 特性

- 🚀 **轻量级**: 使用 `jlink` 工具创建只包含必要模块的自定义 JRE
- 🔧 **多阶段构建**: 分离构建环境和运行环境，减小最终镜像大小
- 🛡️ **安全**: 包含 `su-exec` 工具用于安全的用户切换
- 🌍 **国际化**: 支持中文语言环境设置
- ⚡ **高性能**: 基于 OpenJ9 JVM，提供优秀的性能表现

## 镜像信息

- **基础镜像**: `ibm-semeru-runtimes:open-25-jdk`
- **运行时基础**: `ubuntu:noble`
- **Java 版本**: OpenJDK 25
- **JVM**: OpenJ9

## 包含的 Java 模块

该镜像使用 `jlink` 工具创建了一个包含以下模块的自定义 JRE：

- `java.base` - 核心 Java 类库
- `java.desktop` - 桌面应用支持
- `java.logging` - 日志框架
- `java.naming` - JNDI 命名服务
- `java.net.http` - HTTP 客户端
- `java.sql` - 数据库连接
- `java.sql.rowset` - 数据库行集
- `java.xml` - XML 处理
- `jdk.httpserver` - HTTP 服务器
- `jdk.naming.dns` - DNS 命名服务
- `jdk.unsupported` - 不支持的 API

## 环境变量

- `JAVA_HOME`: `/opt/java/openjdk`
- `PATH`: 包含 Java 二进制文件路径
- `LANG`: `en_US.UTF-8`
- `LANGUAGE`: `en_US:en`
- `LC_ALL`: `en_US.UTF-8`
- `PUID`: `0` (用户 ID)
- `PGID`: `0` (组 ID)
- `UMASK`: `022`
- `TZ`: `Asia/Shanghai`

## 构建镜像

```bash
docker build -t openj9-docker .
```

## 运行容器

### 基本运行
```bash
docker run -it openj9-docker java -version
```

### 运行 Java 应用
```bash
docker run -v /path/to/your/app:/app openj9-docker java -jar /app/your-app.jar
```

### 交互式运行
```bash
docker run -it openj9-docker bash
```

## 使用示例

### 检查 Java 版本
```bash
docker run --rm openj9-docker java -version
```

### 运行简单的 Java 程序
```bash
echo 'public class Hello { public static void main(String[] args) { System.out.println("Hello OpenJ9!"); } }' > Hello.java
docker run -v $(pwd):/app openj9-docker javac /app/Hello.java
docker run -v $(pwd):/app openj9-docker java -cp /app Hello
```

## 项目结构

```
openj9-docker/
├── Dockerfile          # Docker 构建文件
└── README.md          # 项目说明文档
```

## 技术细节

### 多阶段构建

1. **第一阶段 (jre-builder)**:
   - 基于 `ibm-semeru-runtimes:open-25-jdk`
   - 安装和编译 `su-exec` 工具
   - 使用 `jlink` 创建自定义 JRE

2. **第二阶段 (运行时)**:
   - 基于 `ubuntu:noble`
   - 复制自定义 JRE 和必要工具
   - 设置环境变量和语言环境

### 优化措施

- 使用 `jlink` 的 `--strip-debug` 选项移除调试信息
- 使用 `--no-header-files` 和 `--no-man-pages` 移除文档
- 使用 `--compress=2` 进行压缩
- 清理构建依赖以减小镜像大小

## 许可证

本项目遵循相应的开源许可证。请查看 IBM Semeru 和 Ubuntu 的许可证条款。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 相关链接

- [IBM Semeru Runtimes](https://developer.ibm.com/languages/java/semeru-runtimes/)
- [OpenJ9](https://www.eclipse.org/openj9/)
- [Docker 多阶段构建](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/#use-multi-stage-builds)
