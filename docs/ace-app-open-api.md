# ACE App 开放接口说明

面向 App 客户端调用，无需登录（`@Anonymous`）。

## 1. 线上地址

| 方式 | 基址 |
|------|------|
| 推荐（经 Nginx） | `http://hzsdemo.cn/prod-api` |
| 直连后端 | `http://hzsdemo.cn:8888` |

下文路径均接在基址之后。正式启用 HTTPS 后，将 `http` 改为 `https` 即可。

相关代码：

- 控制器：`ace-admin/.../controller/open/AceAppControlOpenController.java`
- 请求体：`ace-team/.../domain/vo/AceAppReportRequest.java`
- 业务实现：`AceAppControlServiceImpl#isEnabled` / `#report`

---

## 2. 查询是否启用（是否禁用）

用于 App 启动时判断当前包是否允许正常使用。

| 项 | 说明 |
|----|------|
| 方法 | `GET` |
| 路径 | `/open/app/enabled` |
| 完整示例 | `http://hzsdemo.cn/prod-api/open/app/enabled?packageName=com.example.app` |
| 鉴权 | 无需 Token |

### 请求参数

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| `packageName` | Query | 是 | App 包名 |

### 成功响应示例

```json
{
  "msg": "操作成功",
  "code": 200,
  "data": true
}
```

### `data` 含义

| 值 | 含义 |
|----|------|
| `true` | 后台已登记该包名，且启用状态为「启用」(`enabled = 1`) |
| `false` | 未登记该包名，或状态为「禁用」(`enabled = 0`)，或包名为空 |

### 判定规则

1. 按 `packageName` 查询 `ace_app_control`
2. 仅当库中 `enabled` 字段等于字符串 `"1"` 时返回 `true`
3. 其余情况返回 `false`（不会抛业务异常）

### 调用建议

App 启动时先调本接口：`false` 则拦截/提示；`true` 再进入正常流程。

---

## 3. 上报收益

用于设备每日收益上报（同一天同一设备可重复上报，服务端按日 upsert）。

| 项 | 说明 |
|----|------|
| 方法 | `POST` |
| 路径 | `/open/app/report` |
| 完整示例 | `http://hzsdemo.cn/prod-api/open/app/report` |
| Content-Type | `application/json` |
| 鉴权 | 无需 Token |

### 请求体

```json
{
  "packageName": "com.example.app",
  "deviceName": "小米13",
  "oaid": "设备OAID字符串",
  "todayIncome": 12.34,
  "revenueShare": 0.2,
  "ipAddress": "1.2.3.4"
}
```

| 字段 | 类型 | 必填 | 约束 | 说明 |
|------|------|------|------|------|
| `packageName` | string | 是 | 非空，最长 200 | 包名，须已在后台 APP 管控中登记 |
| `deviceName` | string | 是 | 非空，最长 200 | 设备名称 |
| `oaid` | string | 是 | 非空，最长 128 | 设备 OAID |
| `todayIncome` | number | 是 | `>= 0.00` | 今日收益（原始 CNY，未乘分成） |
| `revenueShare` | number | 否 | App 可选上报 | 客户端展示分成系数（如 `0.2`）；**后端可忽略** |
| `ipAddress` | string | 否 | 最长 64 | 公网 IP；客户端获取失败时可传 `unknown` |

### 成功响应示例

```json
{
  "msg": "操作成功",
  "code": 200,
  "data": 1
}
```

`data` 为写入影响行数（实现返回值）。

### 服务端行为

1. 校验包名是否存在于 `ace_app_control`；不存在则抛业务异常：`包名不存在:xxx`
2. 按「包名 + OAID + 当天日期」upsert 到 `ace_app_device_income`
3. 汇总该设备累计收益，upsert 到 `ace_app_device`（含设备名、最后上报时间等）

### 注意

- 本接口目前**只校验包名是否存在**，不强制要求 `enabled = 1`
- 是否允许用户使用 App，请以「查询是否启用」接口为准
- 建议每天每设备上报一次；重复上报会覆盖/更新当日收益记录

### 失败示例（包名未登记）

HTTP 仍可能为 200（项目统一业务异常包装时以实际返回为准），业务侧会提示包名不存在。App 应判断 `code != 200` 或错误文案。

---

## 4. 后台配置与字典

### 4.1 业务字段（表 `ace_app_control`）

| 库字段 | Java / 前端字段 | 说明 |
|--------|-----------------|------|
| `package_name` | `packageName` | 包名 |
| `owner_name` | `ownerName` | 归属 |
| `enabled` | `enabled` | 是否启用：`0` 禁用，`1` 启用 |

### 4.2 字典类型

| 业务含义 | 字典类型 `dict_type` | 存库/接口值 | 说明 |
|----------|----------------------|-------------|------|
| 启用状态 | `ace_app_enabled` | `0` / `1` | 禁用 / 启用；SQL 脚本已初始化 |
| **归属** | **`ace_app_owner`** | 字典项的 `dict_value` | 前端 `useDict('ace_app_owner')`；写入字段为 `ownerName` |

说明：

- 归属**不是**开放接口字段，仅后台 APP 管控列表/表单使用
- 页面绑定：`ruoyi-ui/src/views/team/app/index.vue`
- 若后台「归属」下拉为空，需在 **系统管理 → 字典管理** 中维护字典类型 `ace_app_owner` 及其字典数据（当前仓库 `ace_app_control.sql` 仅初始化了 `ace_app_enabled`，未附带归属字典种子数据）

### 4.3 启用状态字典（参考）

| `dict_label` | `dict_value` |
|--------------|--------------|
| 禁用 | `0` |
| 启用 | `1` |

---

## 5. App 推荐调用顺序

```text
1. GET  /open/app/enabled?packageName=xxx
   └─ data == false → 提示禁用并退出
   └─ data == true  → 继续

2. （按业务节奏，如每天一次）
   POST /open/app/report
   Body: packageName / deviceName / oaid / todayIncome
```

后台前置条件：在 **APP管理 / APP管控** 中新增对应包名，设置归属（可选），并将启用状态设为「启用」。

---

## 6. 联调检查清单

- [ ] 基址可达：`/captchaImage` 或本接口返回 JSON
- [ ] 包名已在后台登记且为启用
- [ ] `enabled` 接口对启用包返回 `data: true`
- [ ] `enabled` 接口对禁用/未登记包返回 `data: false`
- [ ] `report` 成功后，后台设备列表能看到 OAID 与收益
- [ ] 走 Nginx 时使用 `/prod-api` 前缀；直连 8888 时不要加此前缀

---

## 7. curl 示例

```bash
# 是否启用
curl "http://hzsdemo.cn/prod-api/open/app/enabled?packageName=com.example.app"

# 上报
curl -X POST "http://hzsdemo.cn/prod-api/open/app/report" \
  -H "Content-Type: application/json" \
  -d "{\"packageName\":\"com.example.app\",\"deviceName\":\"测试机\",\"oaid\":\"test-oaid-001\",\"todayIncome\":1.23}"
```
