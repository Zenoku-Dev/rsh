<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Zenoku-Dev/zenoku-design/main/assets/rsh/readme-banner-animated-dark.svg">
    <img src="https://raw.githubusercontent.com/Zenoku-Dev/zenoku-design/main/assets/rsh/readme-banner-animated.svg" alt="rsh" width="440">
  </picture>
</p>

# rsh

Удалённая оболочка для инфраструктуры zenoku. Команды `rsh` идут через [auth](https://github.com/Zenoku-Dev/auth) (`auth.rival-afk.com`) → VPS → туннель к целевому узлу, поэтому ключи и адреса не нужны локально.

## Примеры

```sh
rsh pc status          # ON / uptime (через WoL-пробуждение и SSH)
rsh pc exec "uptime"   # выполнить команду на узле
rsh pc on|off|reboot   # Wake-on-LAN / выключить / перезагрузить
rsh net resolve pc     # резолв имени узла в адрес
```

Учётка и токены живут в `~/.rsh/` (`rsh id`, `config.json`, `hosts`). Лого и бренд-ассеты — в [rival-afk/zenoku-design](https://github.com/Zenoku-Dev/zenoku-design).

## Сборка

```sh
go build -o rsh .     # Go 1.27
```

## MCP (для агентских харнессов)

`rsh mcp` — stdio MCP-сервер с инструментами `rsh_exec`, `rsh_hosts`, `rsh_status`.
Если rsh вызван из агентского харнесса (opencode, zcode, claude code, codex, antigravity, cursor, windsurf, cline — детект по окружению и /proc), клиент предлагает добавить себя в секцию `mcp` конфига харнесса:

```json
{"mcp":{"servers":{"rsh":{"type":"local","command":["rsh","mcp"]}}}}  (opencode)
```

Отключить подсказку: `RSH_MCP_HINT=0` или `"mcp_hint": false` в `~/.rsh/config.json`.
