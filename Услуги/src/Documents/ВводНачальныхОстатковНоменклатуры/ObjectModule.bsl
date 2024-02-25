

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
		// Определить, нужно ли обновлять дату в движениях.
	ОбновитьДатуДвижений = ЭтоНовый() ИЛИ Движения.ОстаткиМатериалов.Модифицированность();
	Если Не ОбновитьДатуДвижений Тогда

		// Проверить, что дата изменилась.
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ТекущийДокумент", Ссылка);
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	Дата
			|ИЗ 
			|	Документ.ВводНачальныхОстатковНоменклатуры 
			|ГДЕ
			|	Ссылка = &ТекущийДокумент";

		Выборка = Запрос.Выполнить().Выбрать();
		Выборка.Следующий();
		ОбновитьДатуДвижений = Выборка.Дата <> Дата; 

	КонецЕсли;

	// Установить всем новую дату, если нужно.
	Если ОбновитьДатуДвижений Тогда

		Если НЕ Движения.ОстаткиМатериалов.Выбран() И НЕ Движения.ОстаткиМатериалов.Модифицированность() Тогда
			Движения.ОстаткиМатериалов.Прочитать(); 
			
		КонецЕсли;

		Для Каждого ЗаписьРегистра Из Движения.ОстаткиМатериалов Цикл
			ЗаписьРегистра.Период = Дата;
			
		КонецЦикла;

	КонецЕсли;

КонецПроцедуры
