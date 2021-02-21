# Описание работы playbook

[Playbook](site.yml) разделён логически на две части - подготовка инфраструктуры и установка/настройка сервисов. Из-за особенностей тестовой среды нет возможности явно управлять ip-адресами виртуальных машин из оболочки гипервизора (Hyper-V и виртуальные коммутаторы). Так что была выбрана стратегия динамически-генерируемого инвентори [prod.yml](inventory/prod.yml): пользователь сперва должен сгенерировать этот инвентори-файл запуском плейбука, а в дальнейшем может управлять только сервисами.

## Подготовка инфраструктуры

Запустить процедуру можно командой:

```
ansible-playbook -v -i inventory/hypervisors.yml --ask-vault-pass -t init site.yml
```

Происходит подключение к гипервизору и поочередная подготовка виртуальных машин с помощью набора tasks в файле [init.yml](init.yml). Конфигурация желаемого inventory описана в словаре `services_infra` в файле [group_vars/hypervisors/vars.yml](group_vars/hypervisors/vars.yml).

После настройки всех хостов их параметры становятся инвентори-файлом [prod.yml](inventory/prod.yml) из шаблона [inventory.prod.yml.j2](templates/inventory.prod.yml.j2). Если виртуальные машины отсутствовали, то они будут созданы, а если были запущены - будут захвачены их ip-адреса.  
Также после окончания настройки ВМ производится их проверка модулем Ansible `ping`.

Кратко о задачах настройки из файла [init.yml](init.yml) - для управления ВМ используется Vagrant.  
С его помощью можно:
- получить и распарсить статус ВМ и если её не существует - создать
- узнать ip-адрес ВМ
- захватить созданный для пользователя `vagrant` секретный ключ и использовать его для подключения из Ansible

## Установка/настройка сервисов

Все три сервиса имеют свой тег для ограниченного запуска задач. Однако, так как плейбук выполняется довольно быстро и обладает свойством идемпотентности, то возможно проще запускать их все, кроме тэга `init` командой:

```
ansible-playbook -v -i inventory/prod.yml --skip-tags init site.yml
```

Каждый play сервиса имеет параметры, описывающие версию, а также сетевые параметры для настройки доступа к этим сервисам.

Каждый play имеет следующую логику: скачать (если не был скачан ранее) архив с дистрибутивом, распаковать его и сформировать конфигурационные файлы сервиса.

Запуск сервисов предполагается вручную:

- Elasticsearch: `elasticsearch`
- Kibana: `kibana`
- Logstash: `logstash -f ${LS_HOME}/config/logstash.conf`

В playbook встречаются следующие тэги:

- `init`
- `java`
- `skip_ansible_lint`
- `elastic`
- `kibana`
- `logstash`