# Домашнее задание к занятию "08.04 Создание собственных modules"

## Модуль 8. Система управления конфигурациями

### Студент: Иван Жиляев

## Подготовка к выполнению
>1. Создайте пустой публичных репозиторий в любом своём проекте: `my_own_collection`
>2. Скачайте репозиторий ansible: `git clone https://github.com/ansible/ansible.git` по любому удобному вам пути
>3. Зайдите в директорию ansible: `cd ansible`
>4. Создайте виртуальное окружение: `python3 -m venv venv`
>5. Активируйте виртуальное окружение: `. venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении
>6. Установите зависимости `pip install -r requirements.txt`
>7. Запустить настройку окружения `. hacking/env-setup`
>8. Если все шаги прошли успешно - выйти из виртуального окружения `deactivate`
>9. Ваше окружение настроено, для того чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `. venv/bin/activate && . hacking/env-setup`

## Основная часть

>Наша цель - написать собственный module, который мы можем использовать в своей role, через playbook. Всё это должно быть собрано в виде collection и отправлено в наш репозиторий.
>
>1. В виртуальном окружении создать новый `my_own_module.py` файл
>2. Наполнить его содержимым:
>```python
>#!/usr/bin/python
>
># Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
># GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
>from __future__ import (absolute_import, division, print_function)
>__metaclass__ = type
>
>DOCUMENTATION = r'''
>---
>module: my_test
>
>short_description: This is my test module
>
># If this is part of a collection, you need to use semantic versioning,
># i.e. the version is of the form "2.5.0" and not "2.4".
>version_added: "1.0.0"
>
>description: This is my longer description explaining my test module.
>
>options:
>    name:
>        description: This is the message to send to the test module.
>        required: true
>        type: str
>    new:
>        description:
>            - Control to demo if the result of this module is changed or not.
>            - Parameter description can be a list as well.
>        required: false
>        type: bool
># Specify this value according to your collection
># in format of namespace.collection.doc_fragment_name
>extends_documentation_fragment:
>    - my_namespace.my_collection.my_doc_fragment_name
>
>author:
>    - Your Name (@yourGitHubHandle)
>'''
>
>EXAMPLES = r'''
># Pass in a message
>- name: Test with a message
>  my_namespace.my_collection.my_test:
>    name: hello world
>
># pass in a message and have changed true
>- name: Test with a message and changed output
>  my_namespace.my_collection.my_test:
>    name: hello world
>    new: true
>
># fail the module
>- name: Test failure of the module
>  my_namespace.my_collection.my_test:
>    name: fail me
>'''
>
>RETURN = r'''
># These are examples of possible return values, and in general should use other names for return values.
>original_message:
>    description: The original name param that was passed in.
>    type: str
>    returned: always
>    sample: 'hello world'
>message:
>    description: The output message that the test module generates.
>    type: str
>    returned: always
>    sample: 'goodbye'
>'''
>
>from ansible.module_utils.basic import AnsibleModule
>
>
>def run_module():
>    # define available arguments/parameters a user can pass to the module
>    module_args = dict(
>        name=dict(type='str', required=True),
>        new=dict(type='bool', required=False, default=False)
>    )
>
>    # seed the result dict in the object
>    # we primarily care about changed and state
>    # changed is if this module effectively modified the target
>    # state will include any data that you want your module to pass back
>    # for consumption, for example, in a subsequent task
>    result = dict(
>        changed=False,
>        original_message='',
>        message=''
>    )
>
>    # the AnsibleModule object will be our abstraction working with Ansible
>    # this includes instantiation, a couple of common attr would be the
>    # args/params passed to the execution, as well as if the module
>    # supports check mode
>    module = AnsibleModule(
>        argument_spec=module_args,
>        supports_check_mode=True
>    )
>
>    # if the user is working with this module in only check mode we do not
>    # want to make any changes to the environment, just return the current
>    # state with no modifications
>    if module.check_mode:
>        module.exit_json(**result)
>
>    # manipulate or modify the state as needed (this is going to be the
>    # part where your module will do what it needs to do)
>    result['original_message'] = module.params['name']
>    result['message'] = 'goodbye'
>
>    # use whatever logic you need to determine whether or not this module
>    # made any modifications to your target
>    if module.params['new']:
>        result['changed'] = True
>
>    # during the execution of the module, if there is an exception or a
>    # conditional state that effectively causes a failure, run
>    # AnsibleModule.fail_json() to pass in the message and the result
>    if module.params['name'] == 'fail me':
>        module.fail_json(msg='You requested this to fail', **result)
>
>    # in the event of a successful module execution, you will want to
>    # simple AnsibleModule.exit_json(), passing the key/value results
>    module.exit_json(**result)
>
>
>def main():
>    run_module()
>
>
>if __name__ == '__main__':
>    main()
>```
>Или возьмите данное наполнение из [статьи](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html#creating-a-module).
>
>3. Заполните файл в соответствии с требованиями ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, определённом в параметре `path`, с содержимым, определённым в параметре `content`.

Содержимое [модуля](https://github.com/nimlock/netology-my_own_collection/blob/main/plugins/modules/my_own_module.py) без комментарив такое:

``` python
from ansible.module_utils.basic import AnsibleModule

def run_module():
   module_args = dict(
       path=dict(type='str', required=True),
       content=dict(type='str', required=True)
   )

   result = dict(
       changed=False,
       message=''
   )
   current_content = ''

   module = AnsibleModule(
       argument_spec=module_args,
       supports_check_mode=True
   )

   if module.check_mode:
       result['message'] = 'Run in checking mode, no changes.'
       module.exit_json(**result)

   try:
       with open(module.params['path'], 'r') as f:
           current_content = f.read()
   except FileNotFoundError:
       pass
   
   if current_content == module.params['content']:
       result['changed'] = False
       result['message'] = 'Target file {} already exists with given content.'.format(module.params['path'])
   else:
       try:
           with open(module.params['path'], 'w') as f:
               f.write(module.params['content'])
           result['message'] = 'Success with write file {} with given content.'.format(module.params['path'])
           result['changed'] = True
       except Exception:
           result['message'] = 'Something going wrong!'
           module.fail_json(msg='Your request finish with fail :(', **result)

   module.exit_json(**result)

def main():
   run_module()

if __name__ == '__main__':
   main()
```

>4. Проверьте module на исполняемость локально.

Для проверки модуля создадим файл `incoming_args.json` с входящими аргументами:

```json
{
  "ANSIBLE_MODULE_ARGS": {
    "path": "/tmp/module_result_file",
    "content": "Hello, buddy!"
  }
}
```

Саму проверку выполним в запущенном виртуальном окружении командой:

```
python -m ansible.modules.my_own_module incoming_args.json
```

>5. Напишите single task playbook и используйте module в нём.

Плейбук [single_task_playbook.yml](single_task_playbook.yml) подготовлен. Модуль работает благодаря _hacking/env-setup_, а конкретно подмене расположения основной папки с Ansible. То есть playbook запускается "нативно" командой:

```
ansible-playbook single_task_playbook.yml
```

>6. Проверьте через playbook на идемпотентность.

Модуль обеспечивает идемпотентность playbook.

>7. Выйдите из виртуального окружения.
>8. Инициализируйте новую collection: `ansible-galaxy collection init my_own_namespace.my_own_collection`

Команда для инициализации коллекции:

```
ansible-galaxy collection init nimlock.my_own_collection
```

>9. В данную collection перенесите свой module в соответствующую директорию.
>10. Single task playbook преобразуйте в single task role и перенесите в collection. У role должны быть default всех параметров module

Преобразование playbook выполнил, [role](https://github.com/nimlock/netology-my_own_collection/tree/main/roles/single_task_role) доступна для ознакомления.

>11. Создайте playbook для использования этой role.
>12. Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.

Коллекцию оформил, протеггировал и расположил в [репозитории](https://github.com/nimlock/netology-my_own_collection). Также добавил в файл [requirements.yml](requirements.yml) описание этой коллекции.

Playbook для работы с ролью - [playbook_for_test_role.yml](playbook_for_test_role.yml). Для его запуска необходимо провести установку опубликованной коллекции. Получается такой набор команд:

```
ansible-galaxy collection install -r requirements.yml -p ./collections
ansible-playbook playbook_for_test_role.yml
```

Тестирование playbook прошло успешно.

>13. Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.
>14. Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.
>15. Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`
>16. Запустите playbook, убедитесь, что он работает.

Указанный кейс успешно проверен, всё работает как и ожидалось. Единственное изменение, которое пришлось сделать в playbook - добавить имя неймспейса и коллекции - `nimlock.my_own_collection.my_own_module`, так как модуль теперь не в build-in.

>17. В ответ необходимо прислать ссылку на репозиторий с collection

## Необязательная часть

>1. Используйте свой полёт фантазии: Создайте свой собственный module для тех roles, что мы делали в рамках предыдущих лекций.
>2. Соберите из roles и module отдельную collection.
>3. Создайте новый репозиторий и выложите новую collection туда.
>
>Если идей нет, но очень хочется попробовать что-то реализовать: реализовать module восстановления из backup elasticsearch.
