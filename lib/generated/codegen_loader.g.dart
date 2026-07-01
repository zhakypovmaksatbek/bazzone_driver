// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _ru = {
  "otp_page": {
    "title": "Вход в приложение",
    "description": "Введите номер, мы отправим на него код подтверждения ",
    "terms_of_use": "Нажимая “Получить код” вы принимаете условия пользования и политику конфиденциальности",
    "enter_code": "Введите код",
    "sent_code_to_number": "Отправили код на номер:",
    "resend_code": "Отправить код снова",
    "code_expired_description": "Пожалуйста, запросите новый код",
    "code_expired_button": "Запросить новый код",
    "resend_code_again_in": "Отправить код заново через: "
  },
  "button": {
    "get_code": "Получить код",
    "resend_code": "Отправить код снова",
    "cancel": "Отмена",
    "confirm": "Подтвердить",
    "next": "Далее",
    "back": "Назад",
    "done": "Готово",
    "save": "Сохранить",
    "delete": "Удалить",
    "edit": "Редактировать",
    "search": "Поиск"
  },
  "general": {
    "ky": "Кыргызча",
    "ru": "Русский"
  },
  "home_page": {
    "you_are_here": "Вы тут",
    "start_work": "Приступить к работе",
    "finish_work": "Завершить работу",
    "orders_count": "{} заказов",
    "accept": "Принять",
    "decline": "Отклонить",
    "distance_to_client": "До клиента",
    "distance_to_point": "До точки",
    "km": "{} км",
    "en_route_to_client": "В пути к клиенту",
    "en_route_to_destination": "В пути к точке назначения",
    "arrived_at_client": "Ожидание клиента...",
    "complete_order": "Завершить",
    "new_order": "Новый заказ!",
    "online": "Онлайн",
    "accept_order": "Принять заказ",
    "arrived": "На месте",
    "pickup_point": "А",
    "destination_point": "Б",
    "seconds_short": "{}с",
    "minutes_short": "{} мин",
    "order_accepted": "Заказ принят",
    "depart": "Начать поездку",
    "cash_payment": "Оплата наличными",
    "trip_price_with_traffic": "Стоимость поездки с учетом пробок",
    "passenger": "Пассажир",
    "call": "Позвонить",
    "waiting": "Ожидание",
    "trip_review": "Отзыв о поездке",
    "card_payment": "Оплата картой",
    "card_payment_paid": "Оплачено картой",
    "tips_left": "Оставили чаевые",
    "free_waiting": "Бесплатное ожидание",
    "paid_waiting": "Платное ожидание",
    "pickup": "Подача",
    "road": "Дорога",
    "on_the_road": "На дороге",
    "arrival": "Прибытие"
  },
  "wallet_page": {
    "balance": "Баланс",
    "earned": "Заработано",
    "top_up": "Пополнить",
    "my_cards": "Мои карты",
    "more": "Дополнительно",
    "transaction_history": "История транзакций",
    "no_transactions": "Транзакций пока нет"
  },
  "wallet_earned_page": {
    "taxi_park": "Таксопарк",
    "limit": "Лимит",
    "commission": "Комиссия",
    "partnership": "Партнерство",
    "partnership_months": "{} мес",
    "select_card": "Выберите карту"
  },
  "support_page": {
    "title": "Поддержка",
    "notifications": "Уведомления",
    "whatsapp": "What's App",
    "whatsapp_error": "Не удалось открыть WhatsApp",
    "greeting": "Здравствуйте",
    "message_hint": "Сообщение"
  },
  "profile_page": {
    "title": "Профиль",
    "driver": "Водитель",
    "orders": "Заказы",
    "experience": "Опыт",
    "rating": "Рейтинг",
    "trip_history": "История поездок",
    "your_cars": "Ваши автомобили",
    "taxi_park": "Таксопарк",
    "car_diagnostics": "Диагностика авто",
    "photo_diagnostics": "Фотодиагностика",
    "tariffs": "Тарифы",
    "news": "Новости"
  },
  "profile_cars_page": {
    "registration_certificate": "Свидетельство о регистрации",
    "vin_or_state_number": "VIN или гос номер"
  },
  "car_diagnostics_page": {
    "title": "Диагностика авто",
    "back_seat": "Заднее сиденье",
    "front_seat": "Переднее сиденье",
    "left_side": "Левая сторона",
    "right_side": "Правая сторона",
    "front_part": "Передняя часть машины",
    "back_part": "Задняя часть машины",
    "open_trunk": "Открытый багажник",
    "license_front": "Вод. удостоверение (лицевая сторона)",
    "license_back": "Вод. удостоверение (обратная сторона)",
    "next": "Далее"
  },
  "profile_taxi_park_page": {
    "title": "О таксопарке",
    "commission": "{} Комиссия",
    "schedule": "График работы",
    "weekdays": "Пн-Пт",
    "weekends": "Сб-Вс",
    "day_off": "Выходной",
    "address": "Адрес",
    "contacts": "Контакты",
    "more_about": "Подробнее о таксопарке",
    "withdrawal_terms": "Условия вывода средств",
    "change_park": "Изменить таксопарк"
  },
  "profile_trip_history_page": {
    "title": "История заказов",
    "today": "Сегодня",
    "yesterday": "Вчера"
  },
  "profile_settings_page": {
    "title": "Настройки",
    "sound_notifications": "Уведомления со звуком",
    "languages": "Языки",
    "privacy_policy": "Политика конфиденциальности",
    "app_permissions": "Разрешения на приложения",
    "logout": "Выйти из профиля",
    "logout_confirm_title": "Выход",
    "logout_confirm_desc": "Вы уверены, что хотите выйти из профиля?",
    "logout_confirm_yes": "Да, выйти",
    "logout_confirm_no": "Отмена"
  },
  "profile_tariffs_page": {
    "title": "Тарифы",
    "economy": "Эконом",
    "economy_desc": "Меньше комиссии — больше заказов",
    "comfort": "Комфорт",
    "comfort_desc": "Больше дохода за те же километры",
    "comfort_plus": "Комфорт+",
    "comfort_plus_desc": "Выше класс — выше заработок",
    "commission_badge": "1% Комиссия",
    "delivery": "Доставка",
    "delivery_sub": "Subtitle",
    "additional": "Дополнительно",
    "additional_sub": "Subtitle",
    "unlock_instruction": "Чтобы, разблокировать тарифы проведите диагностику"
  },
  "profile_tariffs_addition_page": {
    "title": "Дополнительно",
    "child_seat": "Детское кресло",
    "pet_transport": "Перевозка домашних животных",
    "food_delivery": "Доставка еды"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ru": _ru};
}
