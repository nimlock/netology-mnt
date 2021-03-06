# Домашнее задание к занятию "08.02 Работа с Playbook"

## Модуль 8. Система управления конфигурациями

### Студент: Иван Жиляев

## Подготовка к выполнению
>1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
>2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
>3. Подготовьте хосты в соотвтествии с группами из предподготовленного playbook. 
>4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 

Подготовка выполнена.

## Основная часть
>1. Приготовьте свой собственный inventory файл `prod.yml`.

Для выполнения этого ДЗ лучше использовать виртуальную машину, а не контейнеры: по условиям задания потребуется пошаговая процедура установки и конфигурирования элементов ELK, а это идёт вразрез с идеологией контейнеризации (там всё это должно быть выполнено на стадии подготовки образа). Также работа с ВМ позволит легко проводить проверку на идемпотентность плейбука.  
На данный момент моя рабочая ОС (Kubuntu) размещена в ВМ на хосте с Hyper-V, а он, к сожалению, поддерживает вложенную виртуализацию только на ЦП Intel и только для ВМ с Hyper-V. Так что использовать Vagrant в Kubuntu для поднятия ВМ в локальном VirtualBox не вариант, а выполнять тестовые плейбуки в основной ОС не комильфо.

Так что я написал отдельный play _Prepare infrastructure_, который запускает task [init.yml](playbook/init.yml) для каждого сервиса из словаря `services_infra` в файле переменных [group_vars/hypervisors/vars.yml](playbook/group_vars/hypervisors/vars.yml). Задача этого play - подготовить окружение используя Hyper-V и "наполнить" inventory для последующих play-ев.  
В ходе работы над play добавил файл параметров Ansible для этого проекта [ansible.cfg](playbook/ansible.cfg) для обхода уведомлений при подключении к хостам из inventory; это обеспечивает такая настройка:

```
[defaults]
host_key_checking = False
```

>2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
>3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
>4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
>5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Ошибки были связаны с _рискованными разрешениями_ у скачиваемых и создаваемых файлов и папок. Устранил из добавлением директивы `mode` в соответствующие таски.

>6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
>7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
>8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

Проверки прошли успешно. Сервисы после запуска корректно сконфигурированы и "видят" друг друга.

>9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

Файл с описанием playbook находится в каталоге [playbook/README.md](playbook/README.md).

>10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

## Необязательная часть

>1. Приготовьте дополнительный хост для установки logstash.
>2. Пропишите данный хост в `prod.yml` в новую группу `logstash`.
>3. Дополните playbook ещё одним play, который будет исполнять установку logstash только на выделенный для него хост.
>4. Все переменные для нового play определите в отдельный файл `group_vars/logstash/vars.yml`.
>5. Logstash конфиг должен конфигурироваться в части ссылки на elasticsearch (можно взять, например его IP из facts или определить через vars).
>6. Дополните README.md, протестируйте playbook, выложите новую версию в github. В ответ предоставьте ссылку на репозиторий.

Настройка Logstash добавлена в playbook.
