Процедура ПоискДокументовПоНомеру(СтрокаПоиска, РезультатПоиска, ДопПараметры) Экспорт

	ФрагментНомера = Прав(СтрокаПоиска, СтрДлина(СтрокаПоиска) - 1);
	
	//Если в строке поиска только "№", то ничего не делать;
	Если ФрагментНомера = "" Тогда
		Возврат;
	КонецЕсли;

	// Выбрать документы об оказании услуг с номером, содержащим введенную строку.
	Запрос = Новый Запрос("ВЫБРАТЬ Ссылка, Номер, Представление
						  |ИЗ Документ.ОказаниеУслуги 
						  |ГДЕ Номер ПОДОБНО &ФрагментНомера");
	Запрос.УстановитьПараметр("ФрагментНомера", "%" + ФрагментНомера + "%");
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		// Создать элемент результата поиска и добавить его в коллекцию.
		ЭлементРезультата = Новый ЭлементРезультатаГлобальногоПоиска(
			Выборка.Ссылка, 
			СтрНайтиИВыделитьОформлением(Выборка.Представление, ФрагментНомера)
		);
		РезультатПоиска.Добавить(ЭлементРезультата);
		
	КонецЦикла;
	
КонецПроцедуры
