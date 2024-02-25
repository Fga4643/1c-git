Процедура ОбработкаПроведения(Отказ,Режим)
	Движения.ОстаткиМатериалов.Записывать = Истина;
	Движения.СтоимостьМатериалов.Записывать = Истина;
	Движения.Продажи.Записывать = Истина;
	МенеджерВТ = Новый МенеджерВременныхТаблиц;
	#Область НоменклатураДокумента
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВТ;
	Запрос.Текст =
		"ВЫБРАТЬ
		|    ОказаниеУслугиПереченьНоменклатуры.Номенклатура,
		|    ОказаниеУслугиПереченьНоменклатуры.Номенклатура.ВидНоменклатуры КАК ВидНоменклатуры,
		|    СУММА(ОказаниеУслугиПереченьНоменклатуры.Количество) КАК КоличествоВДокументе,
		|    СУММА(ОказаниеУслугиПереченьНоменклатуры.Сумма) КАК СуммаВДокументе
		|ПОМЕСТИТЬ НоменклатураДокумента
		|ИЗ
		|    Документ.ОказаниеУслуги.ПереченьНоменклатуры КАК ОказаниеУслугиПереченьНоменклатуры
		|ГДЕ
		|    ОказаниеУслугиПереченьНоменклатуры.Ссылка = &Ссылка
		|СГРУППИРОВАТЬ ПО
		|    ОказаниеУслугиПереченьНоменклатуры.Номенклатура,
		|    ОказаниеУслугиПереченьНоменклатуры.Номенклатура.ВидНоменклатуры";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	РезультатЗапроса = Запрос.Выполнить();
	#КонецОбласти
	
	#Область ДвиженияДокумента
	Запрос2 = Новый Запрос;
	Запрос2.МенеджерВременныхТаблиц = МенеджерВТ;
	Запрос2.Текст = "ВЫБРАТЬ
		|    НоменклатураДокумента.Номенклатура,
		|    НоменклатураДокумента.ВидНоменклатуры,
		|    НоменклатураДокумента.КоличествоВДокументе,
		|    НоменклатураДокумента.СуммаВДокументе,
		|    ЕСТЬNULL(СтоимостьМатериаловОстатки.СтоимостьОстаток, 0) КАК Стоимость,
		|    ЕСТЬNULL(ОстаткиМатериаловОстатки.КоличествоОстаток, 0) КАК Количество
		|ИЗ
		|    НоменклатураДокумента КАК НоменклатураДокумента
		|         ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.СтоимостьМатериалов.Остатки(&Период, Материал В (
		|              ВЫБРАТЬ
		|                    НоменклатураДокумента.Номенклатура
		|              ИЗ
		|                    НоменклатураДокумента)) КАК СтоимостьМатериаловОстатки
		|         ПО НоменклатураДокумента.Номенклатура = СтоимостьМатериаловОстатки.Материал
		|         ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ОстаткиМатериалов.Остатки(&Период, Материал В (
		|              ВЫБРАТЬ
		|                    НоменклатураДокумента.Номенклатура
		|              ИЗ
		|                    НоменклатураДокумента)) КАК ОстаткиМатериаловОстатки
		|         ПО НоменклатураДокумента.Номенклатура = ОстаткиМатериаловОстатки.Материал";
	Запрос2.УстановитьПараметр("Период", МоментВремени());
	СтоимостьМатериалов и ОстаткиМатериалов.
	Движения.СтоимостьМатериалов.БлокироватьДляИзменения = Истина;
	Движения.ОстаткиМатериалов.БлокироватьДляИзменения = Истина;
	РезультатЗапроса = Запрос2.Выполнить();   
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ВыборкаДетальныеЗаписи.Количество = 0 Тогда
			СтоимостьМатериала = 0;
		Иначе
			СтоимостьМатериала = ВыборкаДетальныеЗаписи.Стоимость / ВыборкаДетальныеЗаписи.Количество;
		КонецЕсли;
		Если ВыборкаДетальныеЗаписи.ВидНоменклатуры = Перечисления.ВидыНоменклатуры.Материал Тогда
			// регистр ОстаткиМатериалов – Расход
			Движение = Движения.ОстаткиМатериалов.Добавить();
			Движение.Период = Дата;
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Материал = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.Склад = Склад;
			Движение.Количество = ВыборкаДетальныеЗаписи.КоличествоВДокументе;
			// Регистр СтоимостьМатериалов – Расход
			Движение = Движения.СтоимостьМатериалов.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Материал = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.Стоимость = ВыборкаДетальныеЗаписи.КоличествоВДокументе * ВыборкаДетальныеЗаписи.СтоимостьМатериала;
		КонецЕсли;
		// Регистр Продажи
		Движение = Движения.Продажи.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
		Движение.Клиент = Клиент;
		Движение.Мастер = Мастер;
		Движение.Количество = ВыборкаДетальныеЗаписи.КоличествоВДокументе;
		Движение.Выручка = ВыборкаДетальныеЗаписи.СуммаВДокументе;
		Движение.Стоимость = ВыборкаДетальныеЗаписи.КоличествоВДокументе * ВыборкаДетальныеЗаписи.СтоимостьМатериала;
	КонецЦикла;
	Движения.Записать();
	#КонецОбласти
	
	#Область КонтрольОстатков
	Если Режим = РежимПроведенияДокумента.Оперативный Тогда
		// Проверить отрицательные остатки.
		Запрос3 = Новый Запрос;
		Запрос3.МенеджерВременныхТаблиц = МенеджерВТ;
		Запрос3.Текст = "
		||ВЫБРАТЬ
		|    ОстаткиМатериаловОстатки.Материал,
		|    ОстаткиМатериаловОстатки.КоличествоОстаток
		|ИЗ
		|    РегистрНакопления.ОстаткиМатериалов.Остатки( , Материал В (
		|         ВЫБРАТЬ
		|              НоменклатураДокумента.Номенклатура
		|         ИЗ
		|              НоменклатураДокумента)
		|         И Склад = &Склад) КАК ОстаткиМатериаловОстатки
		|ГДЕ
		|    ОстаткиМатериаловОстатки.КоличествоОстаток < 0";
		Запрос3.УстановитьПараметр("Склад", Склад);
		РезультатЗапроса = Запрос3.Выполнить();
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = "Не хватает " + Строка(- ВыборкаДетальныеЗаписи.КоличествоОстаток) + " единиц материала """ + ВыборкаДетальныеЗаписи.Материал + """";
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЦикла;
	КонецЕсли;
	#КонецОбласти
КонецПроцедуры