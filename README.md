⚡ Cobalt x RakNet | UNOFFICIAL
Cobalt — это runtime developer tool для Roblox Game Engine, созданный для мониторинга и перехвата входящего и исходящего сетевого трафика.
Этот форк расширяет оригинальный Cobalt интеграцией RakNet инструментов, открывая новый уровень контроля над сетевым протоколом Roblox.

Status Version RakNet

🔥 Чем отличается от оригинала
Оригинальный Cobalt — это мощный remote spy с красивым UI, но он работает исключительно на уровне RemoteEvent/RemoteFunction/RobloxScriptSignal.
Этот форк добавляет полноценную поддержку RakNet — низкоуровневого протокола, который Roblox использует для всей сетевой коммуникации.

✅ Что было в оригинале
Мониторинг входящих/исходящих remote
Intercept и блокировка remote
Actor support
Pagination
Code generation
File logging
Plugin support
🆕 Что добавлено в этой версии
1. 🧩 RakNet Packet Inspector
Прямой мониторинг сырых RakNet пакетов (не только remote, а всех сетевых операций)
Отображение заголовков пакетов, типов (PacketReliability), каналов
Декодирование Roblox-специфичных payload (Replicate, Instance, Property, Remote)
2. 🛠 RakNet Filtering System
Блокировка пакетов по байт-маске (rnet.setfilter)
Фильтрация по типу пакета (ACK, Data, NAK, etc.)
Whitelist/blacklist отдельных remote на уровне RakNet
3. 📊 Дополнительные вкладки
Packets — полный лог всех Raw RakNet пакетов
Incoming / Outgoing — раздельный просмотр с цветовой индикацией
Hex Viewer — просмотр сырых данных в HEX + ASCII
Spy Controls — управление хуками и фильтрами
4. 🔄 RakNet Engine Integration
Полная совместимость с rnet API (hookSend, hookReceive, setfilter, send)
Автоматическое переключение на hookmetamethod fallback если rnet недоступен
Поддержка как RemoteEvent/RemoteFunction, так и низкоуровневых пакетов
5. ⚡ Производительность
Оптимизированная работа с большим потоком пакетов (500+ в секунду)
Виртуализация списка — не лагает при тысячах записей
Инкрементальный поиск без подвисаний
