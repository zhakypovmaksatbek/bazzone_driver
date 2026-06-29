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
    "order_accepted": "Заказ принят",
    "depart": "Начать поездку"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ru": _ru};
}
