<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/rival-afk/zenoku-design/main/assets/rsh/png/readme-banner-dark.png">
    <img src="https://raw.githubusercontent.com/rival-afk/zenoku-design/main/assets/rsh/png/readme-banner.png" alt="rsh" width="440">
  </picture>
</p>

# rsh

Удалённая оболочка для инфраструктуры zenoku. Команды `rsh` идут через [auth](https://github.com/rival-afk/auth) (`auth.rival-afk.com`) → VPS → туннель к целевому узлу, поэтому ключи и адреса не нужны локально.

## Примеры

```sh
rsh pc status          # ON / uptime (через WoL-пробуждение и SSH)
rsh pc exec "uptime"   # выполнить команду на узле
rsh pc on|off|reboot   # Wake-on-LAN / выключить / перезагрузить
rsh net resolve pc     # резолв имени узла в адрес
```

Учётка и токены живут в `~/.rsh/` (`rsh id`, `config.json`, `hosts`). Лого и бренд-ассеты — в [rival-afk/zenoku-design](https://github.com/rival-afk/zenoku-design).

## Сборка

```sh
go build -o rsh .     # Go 1.27
```
