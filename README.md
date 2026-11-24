# COLDY 补货监控

一个运行在 Windows 上的本地补货监控工具：定时查询有赞商品详情接口，检测商品从「售罄」变为「有货」，然后通过本机声音、Windows 弹窗、手机推送和微信小程序快捷方式提醒你。

> 本项目只做「监控 + 提醒 + 打开页面」，**不自动下单、不绕过验证码、不做批量抢购**。请遵守平台规则，风险自负。
程序里面的打开监控面板，会跳转到浏览器，这个里面一些功能按键功能的实现存在问题，这个你就是提供一个更加美观的界面用于历史数据展示。
还有这个提醒实际上也比较鸡肋，因为有货的时间只会有10几秒。你看到提醒再使用手机打开小程序，大多数时候已经晚了，而且pushplus的推送是服务号在微信里消息不是特别明显。
## 功能特性

- **5 秒轮询**：轮询间隔和随机抖动可配置；
- **库存状态机**：只在「无货 → 有货」时触发提醒，不重复刷屏；
- **多通道通知**：PushPlus、Server酱、企业微信群机器人、飞书群机器人、ntfy；
- **本机提醒**：响铃 + Windows 弹窗 + `ALERT.txt`；
- **自动跳转**：优先激活/打开电脑微信里的 COLDY 小程序，找不到再打开 H5 商品页；
- **本地监控面板**：运行状态、当前库存、历史有货事件、持续时长、错误记录；
- **手动启停**：程序不会开机自启，关闭程序即停止监控；
- **单实例保护**：避免重复启动导致重复提醒。

## 工作流程

```text
启动程序
  ↓
读取 config.json
  ↓
每 5 秒请求商品详情接口
  ↓
解析 soldStatus / stockNum
  ↓
判断：有货 = stockNum > 0 且 soldStatus != "SOLD_OUT"
  ↓
状态从「无货」变为「有货」
  ↓
响铃 + 弹窗 + 手机推送 + 尝试打开小程序/商品页
  ↓
保存状态，继续轮询
```

请求失败会自动退避重试，避免在网络异常或被风控时持续高频请求。

## 快速开始

1. 下载并解压 Release 包；
2. 双击 `启动COLDY监控.vbs`（或桌面快捷方式）；
3. 点击「开始监控」；
4. 点击「打开监控面板」查看运行状态；
5. 不使用时点击「停止监控」或直接关闭程序。

> 直接双击 `COLDY监控.exe` 会带一个控制台窗口，正常使用建议走 `启动COLDY监控.vbs`。

## 使用说明

### 第一次使用

1. 把压缩包解压到一个**固定目录**（例如 `D:\Tools\COLDY监控`）。`COLDY监控.exe` 必须和 `_internal` 文件夹放在同一层，不能只单独复制 exe；
2. 双击 `启动COLDY监控.vbs` 启动（无控制台窗口）。如果系统弹出安全提示，选择「仍要运行」；
3. 在主界面点「开始监控」，状态显示为「监控中」即表示生效；
4. 点「打开监控面板」会在浏览器打开 `http://127.0.0.1:8898/`，用于查看历史有货记录和错误日志；
5. 需要停止时点「停止监控」，或直接关闭程序窗口。

### 换成自己的商品

程序默认监控作者配置的商品。要监控别的商品，编辑程序目录下的 `config.json`（首次运行后自动生成）：

| 字段 | 从哪里获取 |
| --- | --- |
| `app_id` | 小程序 AppID，在微信「更多资料」或小程序链接里可以看到 |
| `kdt_id` | 有赞店铺 ID，在商品 H5 链接或接口参数里 |
| `alias` | 商品别名，在有赞商品链接的 `alias=` 参数里 |
| `title` | 仅用于界面显示，可以随便填 |

改完保存后，点「停止监控」再点「开始监控」让新配置生效。

### 配置手机提醒

1. 在 PushPlus、Server酱、企业微信机器人、飞书机器人里任选一个，申请 token 或 webhook；
2. 填到程序「通知设置」里，或直接写进 `config.json` 对应字段；
3. `notify_provider` 选择渠道，设为 `none` 表示只响铃不推送；
4. 保存后下一次提醒会自动读取新配置，不需要重启。

### 常见问题

- **双击 VBS 没反应**：确认 `COLDY监控.exe` 和 `_internal` 在同一目录；也可以直接双击 `COLDY监控.exe` 看控制台报错。
- **监控面板打不开**：8898 端口可能被占用或被安全软件拦截，修改 `config.json` 里的 `dashboard_port` 后重启程序。
- **提醒总是来不及**：有货窗口通常只有十几秒，5 秒轮询是速度与风控之间的折中。把 `interval_seconds` 调到 3 秒可能更快，但更容易触发有赞风控。
- **微信跳转只能到小程序首页**：电脑微信的小程序快捷方式无法直达商品页，这是平台限制。
- **手机推送不够明显**：PushPlus 是服务号消息，建议同时配置企业微信或飞书机器人，或者改用 ntfy。

## 配置

首次运行会在程序目录生成 `config.json`。也可以复制 `config.example.json` 后修改：

```json
{
  "app_id": "YOUR_APP_ID",
  "kdt_id": "YOUR_KDT_ID",
  "alias": "YOUR_PRODUCT_ALIAS",
  "title": "YOUR_PRODUCT_TITLE",
  "interval_seconds": 5,
  "jitter_seconds": 0.5,
  "timeout_seconds": 15,
  "sound": true,
  "open_wechat_shortcut": true,
  "wechat_shortcut": "",
  "open_browser_on_alert": true,
  "notify_provider": "pushplus",
  "pushplus_token": "",
  "serverchan_sendkey": "",
  "wecom_webhook": "",
  "feishu_webhook": "",
  "ntfy_topic": "",
  "dashboard_port": 8898
}
```

主要字段：

| 字段 | 说明 |
| --- | --- |
| `app_id` / `kdt_id` / `alias` | 有赞小程序和商品参数 |
| `interval_seconds` | 轮询间隔，默认 5 秒 |
| `jitter_seconds` | 随机抖动，避免固定频率 |
| `open_wechat_shortcut` | 有货时是否尝试打开电脑微信小程序 |
| `wechat_shortcut` | 小程序快捷方式完整路径；留空则自动在桌面查找 |
| `open_browser_on_alert` | 找不到小程序时是否打开 H5 商品页 |
| `notify_provider` | 手机通知渠道，设为 `none` 可关闭 |
| `dashboard_port` | 本地面板端口，默认 8898 |

## 手机通知

在程序的「通知设置」里选择渠道并填 token，或直接修改 `config.json`：

| 渠道 | `notify_provider` | 必填字段 |
| --- | --- | --- |
| PushPlus | `pushplus` | `pushplus_token` |
| Server酱 | `serverchan` | `serverchan_sendkey` |
| 企业微信机器人 | `wecom` | `wecom_webhook` |
| 飞书机器人 | `feishu` | `feishu_webhook` |
| ntfy | `ntfy` | `ntfy_topic` |
| 关闭 | `none` | - |

保存后不需要重启监控，下一次提醒会读取新配置。

## 监控面板

程序启动后访问：

```text
http://127.0.0.1:8898/
```

面板提供：

- 当前商品、状态、库存、价格、最近检查时间；
- 监控是否运行、轮询间隔、通知配置；
- 今日检查次数、有货事件、观察到的有货总时长；
- 历史有货记录（开始/结束/持续/库存）；
- 今日错误次数和最近错误；
- 打开微信小程序、打开 H5 商品页、立即检查、打开数据文件夹。

面板只监听 `127.0.0.1`，不会暴露到局域网或公网。

## 数据与隐私

程序运行时会在程序目录生成以下本地文件：

```text
config.json                 商品参数和通知 token
captures/monitor.log        运行日志
captures/monitor_state.json 最近状态
captures/ALERT*.txt         有货提醒
captures/monitor.pid        进程号
```

注意：

- 这些文件**只保存在本机**，不会上传；
- 首次运行生成的 `config.json` 会带默认商品参数（`app_id` / `kdt_id` / `alias`），不含 token，除非你手动填写；
- `config.json` 可能包含 PushPlus 等服务的 token，**不要提交到 Git**；
- `monitor.log` 可能包含本机快捷方式路径（例如桌面路径），发布前请删除 `captures/`；
- 运行过程序的目录里会生成 `config.json` 和 `captures/`；如果要把这个目录上传 GitHub，请先删除它们，或者只提交 `.gitignore` 允许的文件；
- 本项目没有遥测、统计上报或账号系统；
- 仓库中的 `.gitignore` 已忽略 `config.json`、`captures/`、`*.pid`、`*.log`。

## 目录结构

```text
COLDY监控/
├─ COLDY监控.exe           主程序
├─ _internal/              运行库（不要删除）
├─ 启动COLDY监控.vbs       隐藏控制台启动
├─ config.example.json     配置示例
├─ config.json             本机配置（运行时生成，不提交）
├─ captures/               本地日志和提醒（运行时生成，不提交）
└─ README.md
```

## 技术栈

- Python 3.12
- Tkinter 桌面界面
- requests
- 标准库 `http.server` 本地面板
- PyInstaller 打包为 Windows 目录版程序

## 限制

- 电脑微信小程序快捷方式通常只能打开小程序首页，**不能直达商品页**；
- 有货窗口可能只有几秒，5 秒轮询只能尽量提前，不能保证抢到；
- 库存存在「锁库存」情况，接口显示有库存不代表一定能购买；
- 高频请求可能触发有赞风控，出现 403/验证码/超时时建议降低频率或暂停；
- 本项目不提供自动下单、自动支付、验证码识别等能力。

## 免责声明

本项目仅用于个人学习和自用，不构成任何购买建议。使用本工具产生的账号风险、平台风控、网络异常和数据问题由使用者自行承担。
