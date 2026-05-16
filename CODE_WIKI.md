# Biliup 项目 Code Wiki

## 1. 项目概述

### 1.1 项目简介
Biliup 是一个多平台直播录制与上传工具，支持自动录制多个直播平台的内容，并将录制的视频上传到 Bilibili。项目采用混合架构，结合了 Rust、Python 和 Next.js 前端。

### 1.2 核心功能
- 多平台直播录制（支持 20+ 平台）
- Bilibili 视频上传
- 可视化 Web UI 界面
- 自动录播与上传
- 弹幕录制
- 多主播管理

### 1.3 技术栈
- **后端服务**: Rust (Axum 框架)
- **核心引擎**: Python (异步任务处理)
- **前端界面**: Next.js + React + TypeScript
- **数据存储**: SQLite
- **跨语言桥接**: PyO3 (stream-gears)

## 2. 项目架构

### 2.1 整体架构图
```
┌─────────────────────────────────────────────────────────┐
│                     Next.js 前端                         │
│              (React + TypeScript + Semi UI)              │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP/WebSocket
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Rust Web 服务 (Axum)                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │  API 层 + 认证 + 会话管理                       │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │  核心库 - biliup (Bilibili API 客户端)          │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │  stream-gears (Python 绑定)                     │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Python 引擎 (biliup)                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │  下载引擎 + 任务调度                            │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │  插件系统 (20+ 平台支持)                        │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │  弹幕系统                                       │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│              外部服务                                    │
│  - Bilibili API (上传)                                  │
│  - 各大直播平台 API (录制)                              │
└─────────────────────────────────────────────────────────┘
```

### 2.2 目录结构

```
/workspace/
├── app/                          # Next.js 前端应用
│   ├── (app)/                    # 应用路由
│   │   ├── dashboard/            # 空间配置页面
│   │   ├── history/              # 历史记录页面
│   │   ├── job/                  # 直播历史页面
│   │   ├── logviewer/            # 日志查看页面
│   │   ├── streamers/            # 直播管理页面
│   │   └── upload-manager/       # 投稿管理页面
│   ├── (auth)/                   # 认证相关
│   │   └── login/                # 登录页面
│   ├── lib/                      # 工具库
│   ├── ui/                       # UI 组件
│   │   ├── plugins/              # 平台插件组件
│   │   ├── AvatarCard/           # 头像卡片组件
│   │   ├── ThemeButton/          # 主题切换组件
│   │   └── ...
│   └── ...
├── biliup/                       # Python 核心模块
│   ├── Danmaku/                  # 弹幕模块
│   │   ├── douyin_util/          # 抖音工具
│   │   └── paramgen/             # 参数生成
│   ├── common/                   # 通用工具
│   │   ├── tars/                 # Tars 协议
│   │   ├── log.py                # 日志模块
│   │   └── util.py               # 工具函数
│   ├── engine/                   # 核心引擎
│   │   ├── decorators.py         # 装饰器
│   │   ├── download.py           # 下载模块
│   │   └── upload.py             # 上传模块
│   ├── plugins/                  # 平台插件
│   │   ├── huya_wup/             # 虎牙 WUP 协议
│   │   ├── bilibili.py           # Bilibili 插件
│   │   ├── douyin.py             # 抖音插件
│   │   ├── huya.py               # 虎牙插件
│   │   ├── twitch.py             # Twitch 插件
│   │   ├── youtube.py            # YouTube 插件
│   │   └── ...                   # 其他平台
│   ├── __init__.py
│   └── __main__.py               # Python 入口
├── crates/                       # Rust 模块
│   ├── biliup/                   # 核心 Rust 库
│   │   ├── src/
│   │   │   ├── downloader/       # 下载模块
│   │   │   ├── uploader/         # 上传模块
│   │   │   ├── client.rs         # 客户端
│   │   │   └── lib.rs
│   │   └── Cargo.toml
│   ├── biliup-cli/               # CLI 和 Web 服务
│   │   ├── src/
│   │   │   ├── server/           # Web 服务器
│   │   │   │   ├── api/          # API 端点
│   │   │   │   ├── common/       # 通用功能
│   │   │   │   ├── core/         # 核心业务
│   │   │   │   ├── infrastructure/ # 基础设施
│   │   │   │   ├── app.rs        # 应用控制器
│   │   │   │   └── ...
│   │   │   ├── cli.rs            # 命令行接口
│   │   │   ├── main.rs           # 主入口
│   │   │   └── ...
│   │   ├── migrations/           # 数据库迁移
│   │   └── Cargo.toml
│   └── stream-gears/             # Python 绑定
│       ├── src/
│       │   ├── danmaku.rs
│       │   ├── login.rs
│       │   ├── uploader.rs
│       │   └── lib.rs            # PyO3 绑定
│       ├── stream_gears/         # Python 包
│       └── Cargo.toml
├── docs/                         # 文档
├── tauri-app/                    # Tauri 桌面应用
├── Cargo.toml                    # Rust 工作区配置
├── pyproject.toml                # Python 项目配置
├── package.json                  # Node.js 依赖
└── ...
```

## 3. 核心模块详解

### 3.1 Rust 后端模块

#### 3.1.1 `biliup-cli` - Web 服务与 CLI

**文件位置**: [`/workspace/crates/biliup-cli/src/main.rs`](/workspace/crates/biliup-cli/src/main.rs)

**主要功能**:
- 命令行接口 (CLI)
- Web 服务器启动
- 任务调度与执行

**核心命令**:
```rust
enum Commands {
    Login,           // 登录 Bilibili
    Renew,           // 刷新登录凭证
    Upload,          // 上传视频
    Append,          // 追加视频到稿件
    Show,            // 显示视频详情
    DumpFlv,         // 导出 FLV 元数据
    Download,        // 下载视频
    Server,          // 启动 Web 服务
    List,            // 列出已上传视频
}
```

**主要依赖** (Cargo.toml):
- `axum` - Web 框架
- `sqlx` - 数据库 ORM
- `tower-http` - HTTP 中间件
- `axum-login` - 认证框架
- `clap` - CLI 解析
- `tracing` - 日志

#### 3.1.2 应用控制器 (`app.rs`)

**文件位置**: [`/workspace/crates/biliup-cli/src/server/app.rs`](/workspace/crates/biliup-cli/src/server/app.rs)

**主要职责**:
- Web 服务器启动与管理
- 会话管理 (SQLite 存储)
- 认证与授权
- CORS 配置
- 优雅关闭信号处理

**关键组件**:
```rust
struct ApplicationController;

impl ApplicationController {
    async fn serve(
        addr: &SocketAddr,
        enable_login_guard: bool,
        service_register: ServiceRegister,
    ) -> AppResult<()>
}
```

#### 3.1.3 `biliup` - 核心库

**文件位置**: [`/workspace/crates/biliup/src/lib.rs`](/workspace/crates/biliup/src/lib.rs)

**核心模块**:
- `client` - HTTP 客户端
- `downloader` - 下载功能 (FLV, HLS 解析)
- `uploader` - 上传功能 (Bilibili API)
- `error` - 错误处理

**关键工具函数**:
```rust
pub async fn retry<F, Fut, O, E>(f: F) -> Result<O, E>
pub async fn retry_with_config<F, Fut, O, E, P>(...)
```

#### 3.1.4 `stream-gears` - Python 绑定

**文件位置**: [`/workspace/crates/stream-gears/src/lib.rs`](/workspace/crates/stream-gears/src/lib.rs)

**功能**:
- 将 Rust 功能暴露给 Python
- 提供高性能的视频处理功能
- 登录、上传、下载功能的桥接

**主要导出函数**:
```rust
#[pyfunction]
fn download(...)
#[pyfunction]
fn upload(...)
#[pyfunction]
fn login_by_cookies(...)
#[pyfunction]
fn login_by_sms(...)
#[pyfunction]
fn get_qrcode(...)
#[pyfunction]
fn login_by_qrcode(...)
```

### 3.2 Python 引擎模块

#### 3.2.1 入口模块 (`__main__.py`)

**文件位置**: [`/workspace/biliup/__main__.py`](/workspace/biliup/__main__.py)

**功能**:
- 初始化日志配置
- 启动服务
- 清理临时文件

**主要流程**:
```python
def arg_parser():
    logging.config.dictConfig(LOG_CONF)
    asyncio.run(main())

async def main():
    # 清理临时文件
    shutil.rmtree('./cache/temp', ignore_errors=True)
    # 调用 Rust 绑定的主循环
    await loop.run_in_executor(None, stream_gears.main_loop)
```

#### 3.2.2 插件系统

**文件位置**: [`/workspace/biliup/plugins/`](/workspace/biliup/plugins/)

**插件装饰器**:
- `@Plugin.download(regexp=r'...')` - 标记下载插件

**已支持平台**:
- Bilibili ([`bilibili.py`](/workspace/biliup/plugins/bilibili.py))
- 抖音 ([`douyin.py`](/workspace/biliup/plugins/douyin.py))
- 虎牙 ([`huya.py`](/workspace/biliup/plugins/huya.py))
- Twitch ([`twitch.py`](/workspace/biliup/plugins/twitch.py))
- YouTube ([`youtube.py`](/workspace/biliup/plugins/youtube.py))
- 斗鱼 ([`douyu.py`](/workspace/biliup/plugins/douyu.py))
- 快手 ([`inke.py`](/workspace/biliup/plugins/inke.py))
- Acfun ([`acfun.py`](/workspace/biliup/plugins/acfun.py))
- 以及其他 10+ 平台

**插件基类**: `DownloadBase` (在 [`engine/download.py`](/workspace/biliup/engine/download.py))

#### 3.2.3 Bilibili 插件详解

**文件位置**: [`/workspace/biliup/plugins/bilibili.py`](/workspace/biliup/plugins/bilibili.py)

**主要类**: `Bililive`

**核心方法**:
- `acheck_stream()` - 检查直播状态
- `aget_stream()` - 获取直播流地址
- `get_play_info()` - 获取播放信息
- `get_user_status()` - 获取用户状态
- `check_login_status()` - 检查登录状态
- `update_wbi()` - 更新 WBI 签名密钥
- `danmaku_init()` - 初始化弹幕客户端

**配置项**:
- `bili_qn` - 画质选择
- `bili_protocol` - 流协议 (stream/hls_fmp4)
- `bili_cdn` - CDN 选择
- `bili_danmaku` - 是否开启弹幕录制

**WBI 签名系统**:
```python
class Wbi:
    WTS = "wts"
    W_RID = "w_rid"
    UPDATE_INTERVAL = 2 * 60 * 60
    
    def sign(self, query: dict, ts: int = 0)
    def update_key(self, img, sub)
```

### 3.3 Next.js 前端模块

#### 3.3.1 应用布局

**文件位置**: [`/workspace/app/(app)/layout.tsx`](/workspace/app/(app)/layout.tsx)

**主要组件**:
- 侧边栏导航 (Semi UI Nav)
- 主题切换 (ThemeButton)
- 响应式布局 (移动端适配)

**导航菜单**:
1. 主页
2. 录播管理
   - 直播管理
   - 历史记录
3. 投稿管理
4. 空间配置
5. 直播历史
6. 实时日志
7. 任务平台

#### 3.3.2 UI 组件库

**位置**: [`/workspace/app/ui/`](/workspace/app/ui/)

**关键组件**:
- `AvatarCard` - 主播头像卡片
- `ThemeButton` - 主题切换按钮
- `Player` - 视频播放器
- `TemplateModal` - 模板编辑对话框
- `plugins/` - 各平台配置组件

#### 3.3.3 工具库

**位置**: [`/workspace/app/lib/`](/workspace/app/lib/)

- `utils.ts` - 通用工具函数
- `api-streamer.ts` - 直播 API 调用
- `use-streamers.ts` - 直播管理 Hook

## 4. 关键类与函数

### 4.1 Rust 核心类

#### 4.1.1 `ServiceRegister`
- **职责**: 服务注册与依赖注入
- **功能**: 管理数据库连接、业务服务等

#### 4.1.2 `Credential`
- **模块**: `biliup::uploader::credential`
- **职责**: Bilibili 登录凭证管理
- **功能**: 各种登录方式 (SMS, QR, Cookie)

#### 4.1.3 `Uploader`
- **模块**: `biliup::uploader`
- **职责**: 视频上传到 Bilibili
- **功能**: 分片上传、进度管理、稿件提交

### 4.2 Python 核心类

#### 4.2.1 `DownloadBase`
- **模块**: `biliup.engine.download`
- **职责**: 下载插件基类
- **核心方法**:
  - `acheck_stream()` - 检查流状态
  - `danmaku_init()` - 初始化弹幕

#### 4.2.2 `DanmakuClient`
- **模块**: `biliup.Danmaku`
- **职责**: 弹幕录制客户端
- **支持平台**: Bilibili, 抖音, 虎牙, 斗鱼等

#### 4.2.3 `Wbi`
- **模块**: `biliup.plugins`
- **职责**: Bilibili WBI 签名
- **核心方法**:
  - `sign(query, ts)` - 签名请求
  - `update_key(img, sub)` - 更新密钥

### 4.3 前端核心组件

#### 4.3.1 `Layout`
- **位置**: [`/workspace/app/(app)/layout.tsx`](/workspace/app/(app)/layout.tsx)
- **功能**: 应用主布局，包含导航菜单

#### 4.3.2 `ThemeButton`
- **功能**: 主题切换 (浅色/深色/自动)

## 5. 依赖关系

### 5.1 Rust 依赖 (Cargo.toml)

**工作区依赖**:
- `serde` - 序列化
- `tokio` - 异步运行时
- `tracing` - 日志
- `reqwest` - HTTP 客户端
- `axum` - Web 框架
- `sqlx` - 数据库
- `pyo3` (stream-gears) - Python 绑定

### 5.2 Python 依赖 (pyproject.toml)

**核心依赖**:
- `aiohttp` - 异步 HTTP
- `aiofiles` - 异步文件操作
- `httpx` - HTTP 客户端
- `yt-dlp` - 视频下载
- `streamlink` - 流下载
- `ykdl` - 视频下载
- `sqlalchemy` - ORM
- `protobuf` - 协议缓冲
- `async-lru` - LRU 缓存

### 5.3 前端依赖 (package.json)

**核心依赖**:
- `next` - React 框架
- `react` - UI 库
- `@douyinfe/semi-ui` - UI 组件库
- `swr` - 数据获取
- `react-use` - React Hooks

## 6. 数据库设计

**数据库**: SQLite

**迁移文件**: [`/workspace/crates/biliup-cli/migrations/`](/workspace/crates/biliup-cli/migrations/)

**主要表** (from ORM models):
1. `live_streamers` - 直播主播配置
2. `upload_streamers` - 上传配置
3. `hook_step` - 钩子步骤
4. 用户相关表 (认证)

## 7. 项目运行方式

### 7.1 开发环境

#### 7.1.1 前端开发
```bash
cd /workspace
npm install
npm run dev
# 访问 http://localhost:3000
```

#### 7.1.2 Rust 开发
```bash
cd /workspace
# 构建并运行 CLI
cargo run --bin biliup -- server

# 或运行其他命令
cargo run --bin biliup -- login
```

#### 7.1.3 Python 开发
```bash
cd /workspace
# 使用 maturin 开发
maturin develop
python -m biliup
```

### 7.2 生产部署

#### 7.2.1 Docker 部署
```bash
docker-compose up -d
```

#### 7.2.2 直接运行 (已安装)
```bash
# 启动 Web 服务
biliup server --auth

# 访问 http://localhost:19159
```

### 7.3 环境变量

**相关文件**:
- `.env` - 通用环境变量
- `.env.development` - 开发环境
- `.env.production` - 生产环境

## 8. API 端点

**基础路由** (from [`app.rs`](/workspace/crates/biliup-cli/src/server/app.rs)):
- `/v1/ws/logs` - WebSocket 日志流
- 其他 API 端点在 [`server/api/`](/workspace/crates/biliup-cli/src/server/api/)

## 9. 开发指南

### 9.1 添加新平台插件

1. 在 [`biliup/plugins/`](/workspace/biliup/plugins/) 创建新文件
2. 继承 `DownloadBase` 类
3. 使用 `@Plugin.download()` 装饰器注册 URL 匹配
4. 实现 `acheck_stream()` 方法
5. 在前端添加相应配置组件

### 9.2 修改 Rust 核心库

1. 修改 [`crates/biliup/`](/workspace/crates/biliup/) 中的代码
2. 重新构建: `cargo build`
3. 如需更新 Python 绑定，修改 [`stream-gears`](/workspace/crates/stream-gears/)

### 9.3 前端开发

- 使用 Semi UI 组件库
- 遵循 Next.js App Router 模式
- 添加新页面时，在导航菜单中注册

## 10. 注意事项

### 10.1 免责声明
- 本项目仅供个人学习和研究使用
- 使用时请遵守各平台的服务条款和版权规定
- 禁止用于商业用途

### 10.2 安全建议
- 使用 `--auth` 选项启用登录保护
- 妥善保管 Bilibili 登录凭证
- 定期更新到最新版本

### 10.3 性能优化
- 配置适当的 CDN 选择
- 合理设置录制质量
- 定期清理临时文件

---

**项目版本**: 1.1.29  
**最后更新**: 2026-05-16
