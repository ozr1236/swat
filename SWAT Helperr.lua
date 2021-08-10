script_name('SWAT Helper')
script_description('Удобный помощник для SWAT.')
script_author('Vilgot_Lausen')
script_version_number(46)
script_version('1.1')
script_dependencies('imgui; samp events; lfs')

require 'moonloader'
local dlstatus					= require 'moonloader'.download_status
local inicfg					= require 'inicfg'
local vkeys						= require 'vkeys'
local imguicheck, imgui			= pcall(require, 'imgui')
local sampevcheck, sampev		= pcall(require, 'lib.samp.events')
local encodingcheck, encoding	= pcall(require, 'encoding')
local lfscheck, lfs 			= pcall(require, 'lfs')
local online = import "resource/TimerOnline.lua"
local ScreenX, ScreenY 			= getScreenResolution()
local bNotf, notf = pcall(import, "imgui_notf.lua")
local lections 					= {}
local questions					= {}
local ruless					= {}
local dephistory				= {}

local bloknot = imgui.ImBuffer(100000)
local buff = imgui.ImBuffer(1024)
local name1 = imgui.ImBuffer(256)
local balls = imgui.ImInt(0)
local nicki = imgui.ImBuffer(256)
local balans = imgui.ImInt(0)
local btn_size       = imgui.ImVec2(165,45)
local priz = imgui.ImBuffer(256)
local igratball = imgui.ImBuffer(2)
local combach = imgui.ImInt(0)
local default_questions = {
	active = { redact = false },
	questions = {
		{bname = 'Связь с БЛВ',bq = 'Нашему сотруднику стало плохо. Свяжись с больницей ЛВ и скажи, что необходима карета скорой помощи',bhint = '/d [SWAT] - [LVMC] text'},
		{bname = 'Связь с ТСР',bq = 'У нас склад заканчивается. Свяжись с ТСР и попроси их доставить парочку фур, предложи сопровождение.',bhint = '/d [SWAT] - [MSP] text'},
		{bname = 'Связь с любой армией',bq = '',bhint = '/d [SWAT] - [LSa/SFa/MSP] text, or /d [СВАТ] - [МО] text'},
		{bname = 'Связь с LSa',bq = 'Уведоми Армию Лос-Сантоса о том, что ты влетаешь в воздушное пространство их базы.',bhint = '/d [SWAT] - [LSa] text'},
		{bname = 'Связь c ПД или армией',bq = 'Свяжись с любым ПД или Армией и предложи им совместную тренировку.',bhint = '/d [СВАТ] - [ПД/МО] text'},
		{bname = 'Связь с ФБР во время ЧС',bq = 'В штате ЧС, уведоми ФБР о готовности СВАТ, уточни кол-во людей и точку сбора.',bhint = '/d [SWAT] - [FBI] text'},
		{bname = '',bq = '',bhint = ''},
		{bname = '',bq = '',bhint = ''},
		{bname = '',bq = '',bhint = ''},
		{bname = '',bq = '',bhint = ''},
		{bname = '',bq = '',bhint = ''},
		{bname = '',bq = '',bhint = ''},
	}
}

local default_lect = {
	active = { bool = false, name = nil, handle = nil },
	data = {
		{
			name = 'Повышения',
			text = {
				'Доброго времени суток, коллеги.',
				'Скажу пару слов про повышение в нашей организации.',
				'Повышение даёт вам больше возможностей и высокую зарплату.',
				'Повышение дает уважение среди старшего состава и контроль над младшим.',
				'Повышаясь, у Вас появляется возможность быть в гуще событий нашего...',
				'...подразделения. Хотите чего-то добиться? Тогда повышайтесь!'
			}
		},
		{
			name = 'Виды систем повышений',
			text = {
				'Минуточку внимания!',
				'Хотелось бы Вам напомнить, что у нас действует два вида повышений.',
				'Первый: безотчётный, Вы повышаетесь исключительно по усмотрению Директора, его заместителя',
				'Чтобы Вас по ней повысили, необходимо работать и выполнять обязанности',
				'Второй: отчётный, здесь Вам нужно выполнять задания, которые приведены в сис-ме повышений.',
				'Также хотелось бы сказать, что безотчётная система касается лишь мл.состава',
				'Повышение по безотчётной системе будет происходить не всегда.',
				'Поэтому не ждите чуда.',
				'А повышайтесь по системе отчётности, это в разы эффективней и разумней!'
			}
		},
		{
			name = 'Дискорд,ВК',
			text = {
				'Напоминаю, если вы являетесь 2+ рангом и у вас нет Дискорда',
				'А также, если Вы не состоите в конференции ВК, то вы не сможете повыситься.',
				'Каким образом вступить в конфу ВК и зайти в ДС - можно узнать на форуме.'
			}
		},
		{
			name = 'Как не получить варн?',
			text = {
				'Не хочешь получить варн по-глупости? Тогда не забывай, что тебе...',
				'...постоянно нужно вести запись своего экрана, будь то арест...',
				'...выдача розыска или какая-либо другая ситуация.'
			}
		},
		{
			name = 'Переводы',
			text = {
				'В наше подразделение нужны новые сотрудники, в особенности стажёры.',
				'Поэтому при возможности и при контакте с сотрудниками МО и МЮ 4+',
				'Старайтесь зазывать их к нам, вкратце рассказывая об организации.'
			}
		},
		{
			name = 'F.A.Q.',
			text = {
				'Всё то, что вам нужно сдавать для повышения, есть на форуме...',
				'...в теме: *Система повышений*, всё помечено ссылками.',
				'Либо пользуйтесь темой: *F.A.Q.* на форуме, в разделе SWAT.'
			}
		},
		{
			name = 'Правила РП отыгровок',
			text = {
				'Снова отказали отчёт за плохие РП отыгровки?',
				'У меня есть для тебя решение.',
				'На форуме, в разделе SWAT, есть закрытая тема: *Правила РП отыгровок*',
				'Прочти всё, что там написано, учти это и используй в своих отыгровках.',
				'Если ты сделаешь всё правильно, то поверь, повышение будет не за горами.'
			}
		}
	}
}


------------------------






------------------------



local default_rules = {
{
		name = 'Правила гос. структур',
		text = {
			'{FF0000}Кадровая система',
			
			'Перевестись в Центральный Аппарат из других министерств и из него в другие министерства - нельзя.'
		}
	},
	{
		name = 'Устав Министерства Юстиции',
		text = {
		'Глава 1. Общее положение.',
		'1.1 За любое нарушение устава, сотрудник Министерства Юстиции должен понести наказание (выговор/понижение/увольнение/занесение в Черный Список).',
		'1.2 Устав является общепринятым и обязателен для исполнения всеми сотрудниками МЮ.',
		' ',
		'Глава 2. Права и полномочия сотрудников полицейской академии (P.A).',
		' ',
		'2.1 Сотрудником полицейской академии является стажер любого полицейского департамента.',
		'2.2 Учащиеся полицейской академии являются сотрудниками полицейского департамента, но не имеют никаких дополнительных привилегий.',
		'2.3 Сотруднику полицейской академии запрещено использовать служебный транспорт',
		'2.4 Сотруднику полицейской академии запрещено брать/покупать табельное оружие.',
		'2.5 Сотруднику полицейской академии запрещено покидать территорию полицейского департамента (исключение: участие в тренировке с разрешением начальника/заместителя полицейской академии).',
		'2.6 Сотруднику полицейской академии запрещено нарушать субординацию.',
		'2.7 Сотруднику полицейской академии запрещено спать на посту.',
		'2.8 Сотруднику полицейской академии запрещено покидать свой пост без ведома старшего состава.',
		'2.9 Сотруднику полицейской академии запрещено использовать рацию департамента.',
		'2.10 Сотруднику полицейской академии разрешено использовать тренировочный бронежилет.',
		'2.11 Сотруднику полицейской академии разрешено использовать дубинку с разрешением начальника/заместителя полицейской академии, в целях обучения.',
		'2.12 Сотрудник полицейской академии имеет право на обеденный перерыв.',
		'2.13 Сотрудник полицейской академии имеет право задавать различные вопросы старшему по рангу.',
		'2.14 Сотруднику полицейской академии запрещено выпрашивать документы удостоверяющую личность.',
		'2.15 Сотруднику полицейской академии запрещено увольняться по собственному желанию, будучи учащимся в полицейской академии, не завершив в ней обучение.',
		'2.16 Сотрудник полицейской академии имеет право сдавать экзамен на знание устава, единого федерального кодекса и других нормативно-правовых актов регулирующих работу в министерства юстиции в здании своего департамента.',
		' ',
		'Глава 3. Основные обязанности сотрудников Министерства Юстиции.',
'3.1 Знать и соблюдать Устав Министерства Юстиции, Единый федеральный кодекс, Конституцию штата Yuma, правила пользования волной департамента и прочие нормативно-правовые акты Штата Yuma регулирующие работу...',
'... Министерства Юстиции.',
'3.2 Поиск и задержание преступников на территории юрисдикции полицейских департаментов и прилегающих поселков.',
'3.3 Исполнять приказы старших по званию/должности.',
'3.4 Обеспечение безопасности жизнедеятельности граждан.',
'3.5 Уважительно относится к гражданам.',
'3.6 Бороться с нарушениями Единого Федерального Кодекса штата.',
'3.7 Сотрудник полицейского департамента обязан сообщать о погоне и обстановке, которая происходит вокруг него, а так же, докладывать о выезде на вызов.',
'3.8 Объективно оценивать обстановку вокруг себя/на посту. Быть всегда готовым к любому происшествию.',
'3.9 При получении информации о предстоящем преступлении незамедлительно сообщать в рацию старшим по званию.',
'3.10 Сотрудник полицейского департамента имеет право на недельный отдых.',
'3.11 Сотрудник Министерства Юстиции обязан зачитывать преступнику его права.(Зачитывать Миранду)',
'3.12 Сотрудники министерства юстиции могут присутствовать на собеседованиях, по просьбе проводящих.',
'3.13 При обнаружении нарушения Единого Федерального Кодекса одного из сотрудников, сотрудник министерства юстиции обязан доложить об этом старшему по рангу. При игнорировании данного правила, сотрудник понесет наказание.',
'3.14 Содержание служебного транспорта в исправном состоянии. За намеренную или случайную порчу, сотрудник обязан привести транспорт в рабочее состояние без возмещения денежных средств от руководства департамента.',
'3.15 После патрулирования сотрудники обязан вернуть транспорт на парковку для дальнейшего использования другим экипажем.',
'3.16 Сотрудникам запрещено носить спец. Форму "SWAT", если они не имеют никакого отношения к "SWAT".(исключение: Чрезвычайная Ситуация, разрешение Сената.)',
'3.17 Каждый сотрудник Министерства Юстиции обязан быть авторизован в специальной рации Discord.',
'3.18 Каждый сотрудник Министерства Юстиции должен иметь доказательства на снятие розыска, которые он должен предоставить по просьбе высшего руководства (ФБР, Сенат. Примечание: под словом "Сенат" подразумевается...',
'...Администрация сервера). Хранить доказательства нужно в течении четырех дней. Не предоставление доказательства карается увольнением/понижением/выговором/занесением в Черный Список.',
' ',
'Глава 4. Рабочее время.',
'Рабочий день:',
'» Понедельник - Пятница: 9:00 - 20:00',
'» Суббота - Воскресенье: 9:00 - 18:00',
'» Обеденный Перерыв: 13:00 - 14:00',
'» Вечерний Перерыв(В субботу/Воскресенье отсутствует): 16:00 - 17:00',
' ',
'Глава 5. Сотрудникам МЮ запрещено.',
'5.1 Запрещено использовать служебный транспорт в личных целях наказание: выговор на второй раз увольнение',
'5.2 Запрещено посещать другие полицейские департаменты без разрешения руководящего состава этого департамента наказание:на первый раз беседа на второй раз выговор',
'5.3 Запрещено прикрывать преступные синдикаты/группировки наказание:Увольнение',
'5.4 Запрещено использовать служебный транспорт не по должности. наказание:Устное предупреждение на второй раз выговор',
'5.5 Запрещено заниматься автоугоном/продажей табельного оружия/использование рабочего оружия в личных целях (в любое время суток). наказание:Увольнение',
'5.6 Запрещено отказывать в помощи гражданам, которые пострадали в той, либо иной ситуации.наказание:Выговор',
'5.7 Запрещено спать на посту/в патруле (AFK более 300 секунд).наказание:Выговор',
'5.8 Запрещено употреблять алкоголь в рабочее время.наказание:От выговора до увольнения',
'5.9 Запрещено унижать сотрудников полицейской академии, а так же сотрудников полицейских департаментов наказание:Выговор',
'5.10 Запрещено нарушать Единый Федеральный Кодекс, Конституцию штата и другие административные документы наказание: Увольнение',
'5.11 Запрещено хранить/употреблять наркотические средства наказание: Увольнение',
'5.12 Запрещено выезжать на вызов одному. Исключение: В штате(/members) меньше 7-и человек наказание: на первый раз предупреждение,на второй раз выговор',
'5.13 Запрещено выпрашивать и намекать на повышение наказание:Выговор',
'5.14 Запрещено улучшать навыки стрельбы в рабочее время (исключение: тренировка, разрешение лидера/заместителя)наказание:Выговор',
'5.15 Запрещено игнорировать преступления, совершаемые гражданскими и другими лицами, находящимися на территории города наказание: Выговор',
'5.16 Запрещено занимать/покидать/находится на посту, при этом не делая докладов в рацию наказание:Выговор',
'5.17 Запрещено самовольно менять/выбирать пост. наказание:Устное предупреждение ,на второй раз выговор',
'5.18 Запрещено использовать личный транспорт в рабочее время наказание: выговор',
'5.19 Запрещено играть в казино в рабочее время.наказание: увольнение',
'5.20 Запрещено снимать розыск без каких-либо доказательств наказание: Увольнение',
'5.21 Запрещено категорически брать взятки наказание: Увольнение',
'5.22 Запрещено открывать огонь по нарушителю без весомой причины наказание: Увольнение',
'5.23 Запрещено вымогать документы, удостоверяющие личность, без предоставления удостоверения.наказание:Выговор на второй раз увольнение',
'5.24 Запрещено иметь связи с преступными организациями наказание: Увольнение',
'5.25 Запрещено нарушать неприкосновенность должностного лица наказание: Увольнение',
'5.26 Запрещено спать на рабочем месте больше 15 минут (900 секунд)наказание: Выговор',
'5.27. Запрещено проезжать в опасном районе во время захвата территорий среди банд. Преступников попавших в такую зону нужно выслеживать пока они её не покинут. Наказание за нарушение: по правилам сервера Warn.',
'5.28. Запрещено приезжать на территории на которых проводятся стрелы за бизнесы у мафий. Преступников попавших в такую зону нужно выслеживать пока они её не покинут. Наказание за нарушение: по правилам сервера Warn.',
'5.29 Запрещено носить маски в рабочее время. Исключение: сотрудники SWAT, FBI (Директор ФБР, СВАТ и их заместители в обычное рабочее время, в полицейской форме не должны носить маски. Использовать их можно в случае ЧС, облавы...',
'... и т.п. Директор и его заместители являются официальными лицами, представляющими организацию), Чрезвычайная Ситуация или разрешение от Сената.',
'5.30 Запрещено носить служебную форму в личных целях наказание: увольнение',
'5.31 Запрещено проводить задержание на мотоцикле. Для проведения задержания нужно запросить полицейскую машину. наказание: Выговор,на второй раз увольнение',
'5.32 Запрещено находится на посту без служебного транспорта (автомобиль) своего департамента наказание: устное предупреждение ,второй раз выговор',
'5.33 Запрещено спать в рабочее время и делать вид , что работаете [Afk no esc] наказание: Выговор',
'5.34 Запрещено спать/отдыхать не в комнате отдыха. наказание:Устное предупреждение,второй раз выговор',
'5.35 Запрещено уходить в неактив в 7+ дней без составленного отпуска.наказание: Увольнение',
'5.36 Сотруднику до 8 ранга запрещено заходить без разрешения в кабинет директора: выговор.',
'5.37 Запрещено прогуливать рабочий день без формы. Наказание: выговор.',
'5.38 Запрещено прогуливать рабочий день в форме. Наказание: с 1 по 4 должность - увольнение, с 5 должности и выше: выговор.',
'5.39 Запрещено эвакуировать машины без док-в. Наказание: выговор',
'5.40 Запрещается брать авто "Инфорсер" до 5 должности. Наказание: выговор.',
'5.41 Запрещается брать авто "Ранчер" до 7 должности. Наказание: выговор.',
'5.42 Запрещается брать авто "БТР" до 6 должности. Наказание: выговор.',
'5.43 Запрещается брать вертолет "Маверик" до 7 должности. Наказание: выговор.',
' ',
'Глава 6. Сотрудникам разрешено.',
'6.1 Разрешено требовать от граждан и должностных лиц прекращения нарушений Единого Федерального Кодекса.',
'6.2 Разрешено доставлять правонарушителей в полицейский участок.',
'6.3 Разрешено проверять у граждан и должностных лиц документы, удостоверяющие личность, если есть на то законные основания (Исключение: Сотрудники ФБР и СВАТ). За просьбу документов, без оснований, сотрудник получит: выговор',
'6.4 Разрешено доставлять в участок полицейского департамента лица, подозреваемые в совершенном преступлении.',
'6.5 Разрешено лишать вод.удостоверения за нарушение Правил Дорожного Движения, так же выписывать штрафы за несоблюдение ПДД.',
'6.6 Разрешено осуществлять обыск граждан, если есть на то законные основания.',
'6.7 Разрешено останавливать транспортное средство для проверки документов, а так же для обыска на незаконные предметы, если есть на то законные основания.',
'6.8 Разрешено отстаивать права и законы согласно конституции штата и Единого Федерального Кодекса.',
'6.9 Разрешено проводить аресты в местах массового скопления людей только в паре.(Исключение: ФБР имеют право проводить арест в одиночку).',
'6.10 Разрешено обучаться стрельбе вне рабочего времени.',
'6.11 Разрешено запрашивать помощь по рации.',
'6.12 Разрешено носить аксессуары по типу черных очков, шляпа шерифа или же кепка POLICE, звезда шерифа.',
'6.13 Сотрудникам разрешено патрулировать окрестности своего района на мотоциклах.',
'6.14 Разрешено проводить патруль, выдачу штрафов, проверку документов (только при резких причинах, просто так нельзя требовать) одному на мотоцикле.',
'6.15 Сотрудник при погоне за преступником, имеет право нарушать юрисдикцию.',
'6.16 Находится в опасном районе с напарниками строго в масках в количестве от трех человек. В ночное время с 23:00 до 09:00 разрешено находится в опасном районе строго в масках с напарниками в количестве от двух человек.',
'6.17 Разрешено принимать Устав министерства юстиции, Единый Федеральный Кодекс и другие нормативно-правовые акты регулирующие работу в министерства юстиции только в здании своего департамента.',
'6.18 Игнорировать приказы солдат из армии (любого звания), других полицейских департаментов. Исключение: Сотрудники ФБР старшего состава(От 5+ ранга),Полковник/Генерал(при нахождении на зоне армии), зам.шефы /шефы, сотрудники Правительства с 8 по счету должности, Сенат).',
'6.19 Сотрудникам МЮ/СВАТ 7-10 ранга разрешено ловить преступников(1-2 зв) в одиночку, ФБР от 3 ранга.',
' ',
'Глава 7. Правила построения.',
'7.1 Время построения ровно 5 минут.',
'7.2 Запрещено использовать, применять какие-либо жесты в строю.наказание:Выговор',
'(Исключение: /anims 29, так же /anims 32 и 89 остальные анимации запрещены).',
'7.3 Запрещено нарушать дисциплину в строю.наказание:Выговор',
'7.4 Запрещено использовать рацию в строю.наказание:Выговор',
'7.5 Запрещены любые виды разговоров в строю.наказание:Выговор',
'7.6 Запрещено использовать телефон в строю.наказание:Выговор',
'7.7 Запрещено держать оружие в строю (исключение: Чрезвычайная Ситуация).наказание:Выговор',
		'7.8 Неявка в строй в течении 5 минут. Наказание: Выговор'}
	}
}

local configuration = inicfg.load({
	main_settings = {
		myrankint = 0,
		gender = 0,
		style = 0,
		rule_align = 1,
		lection_delay = 10,
		myname = '',
		myrank = '',
		myaccent = '',
		astag = 'SWAT',
		forma_post = '/r Уважаемые сотрудники, довожу до сведения, что на данный момент проходит строй в гараже. Неявка - выговор. Времени: ',
		useservername = true,
		useaccent = false,
		createmarker = false,
		dorponcmd = true,
		replacechat = true,
		noscrollbar = true,
		playdubinka = true,
		changelog = true,
		usefastmenu = 'E',
		RChatColor = 4282626093,
		DChatColor = 4294940723,
		ASChatColor = 4281558783
	},
	imgui_pos = {
		posX = 100,
		posY = 300
	},
	BindsName = {},
	BindsDelay = {},
	BindsType = {},
	BindsAction = {},
	BindsCmd = {},
	BindsKeys = {}
}, 'SWAT Helper')

-- fAwesome5
	local fa = {
		['ICON_FA_USER_COG'] = '\xef\x93\xbe',
		['ICON_FA_FILE_ALT'] = '\xef\x85\x9c',
		['ICON_FA_KEYBOARD'] = '\xef\x84\x9c',
		['ICON_FA_PALETTE'] = '\xef\x94\xbf',
		['ICON_FA_BOOK_OPEN'] = '\xef\x94\x98',
		['ICON_FA_INFO_CIRCLE'] = '\xef\x81\x9a',
		['ICON_FA_SEARCH'] = '\xef\x80\x82',
		['ICON_FA_ALIGN_LEFT'] = '\xef\x80\xb6',
		['ICON_FA_ALIGN_CENTER'] = '\xef\x80\xb7',
		['ICON_FA_ALIGN_RIGHT'] = '\xef\x80\xb8',
		['ICON_FA_TRASH'] = '\xef\x87\xb8',
		['ICON_FA_REDO_ALT'] = '\xef\x8b\xb9',
		['ICON_FA_LOCK'] = '\xef\x80\xa3',
		['ICON_FA_COMMENT_ALT'] = '\xef\x89\xba',
		['ICON_FA_HAND_PAPER'] = '\xef\x89\x96',
		['ICON_FA_FILE_SIGNATURE'] = '\xef\x95\xb3',
		['ICON_FA_REPLY'] = '\xef\x8f\xa5',
		['ICON_FA_USER_PLUS'] = '\xef\x88\xb4',
		['ICON_FA_USER_MINUS'] = '\xef\x94\x83',
		['ICON_FA_EXCHANGE_ALT'] = '\xef\x8d\xa2',
		['ICON_FA_USER_SLASH'] = '\xef\x94\x86',
		['ICON_FA_USER'] = '\xef\x80\x87',
		['ICON_FA_FROWN'] = '\xef\x84\x99',
		['ICON_FA_SMILE'] = '\xef\x84\x98',
		['ICON_FA_VOLUME_MUTE'] = '\xef\x9a\xa9',
		['ICON_FA_VOLUME_UP'] = '\xef\x80\xa8',
		['ICON_FA_STAMP'] = '\xef\x96\xbf',
		['ICON_FA_ELLIPSIS_V'] = '\xef\x85\x82',
		['ICON_FA_ARROW_UP'] = '\xef\x81\xa2',
		['ICON_FA_ARROW_DOWN'] = '\xef\x81\xa3',
		['ICON_FA_ARROW_RIGHT'] = '\xef\x81\xa1',
		['ICON_FA_SPINNER'] = '\xef\x84\x90',
		['ICON_FA_TERMINAL'] = '\xef\x84\xa0',
		['ICON_FA_CLOUD_DOWNLOAD_ALT'] = '\xef\x8e\x81',
		['ICON_FA_LAYER_GROUP'] = '\xef\x97\xbd',
		['ICON_FA_LINK'] = '\xef\x83\x81',
		['ICON_FA_CAR'] = '\xef\x86\xb9',
		['ICON_FA_MOTORCYCLE'] = '\xef\x88\x9c',
		['ICON_FA_FISH'] = '\xef\x95\xb8',
		['ICON_FA_SHIP'] = '\xef\x88\x9a',
		['ICON_FA_CROSSHAIRS'] = '\xef\x81\x9b',
		['ICON_FA_SKULL_CROSSBONES'] = '\xef\x9c\x94',
		['ICON_FA_ARCHIVE'] = '\xef\x86\x87',
		['ICON_FA_PLUS_CIRCLE'] = '\xef\x81\x95',
		['ICON_FA_PAUSE'] = '\xef\x81\x8c',
		['ICON_FA_PEN'] = '\xef\x8c\x84',
		['ICON_FA_TIMES'] = '\xef\x80\x8d',
		['ICON_FA_QUESTION_CIRCLE'] = '\xef\x81\x99',
		['ICON_FA_MINUS_SQUARE'] = '\xef\x85\x86',
		['ICON_FA_CLOCK'] = "\xef\x80\x97",
		['ICON_FA_COG'] = "\xef\x80\x93"
	}
	
	setmetatable(fa, {
		__call = function(t, v)
			if (type(v) == 'string') then
				return t['ICON_' .. v:upper()] or '?'
			elseif (type(v) == 'number' and v >= 0xf000 and v <= 0xf83e) then
				local t, h = {}, 128
				while v >= h do
					t[#t + 1] = 128 + v % 64
					v = math.floor(v / 64)
					h = h > 32 and 32 or h / 2
				end
				t[#t + 1] = 256 - 2 * h + v
				return string.char(unpack(t)):reverse()
			end
			return '?'
		end,
	
		__index = function(t, i)
			if type(i) == 'string' then
				if i == 'min_range' then
					return 0xf000
				elseif i == 'max_range' then
					return 0xf83e
				end
			end
		
			return t[i]
		end
	})
-- fAwesome5

-- rkeys
	function keybindactivation(numb)
		local temp = 0
		local temp2 = 0
		for _ in tostring(configuration.BindsAction[numb]):gmatch('[^~]+') do
			temp = temp + 1
		end
		inprocess = true
		for bp in tostring(configuration.BindsAction[numb]):gmatch('[^~]+') do
			temp2 = temp2 + 1
			sampSendChat(tostring(bp))
			if temp2 ~= temp then
				wait(configuration.BindsDelay[numb])
			end
		end
		inprocess = false
	end
--rkeys

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then
	return end
	while not isSampAvailable() do
		wait(200)
	end
	local checking = checkbibl()
	while not checking do
		wait(200)
	end
	if not doesFileExist('moonloader/config/SWAT Helper.ini') then
        if inicfg.save(configuration, 'SWAT Helper.ini') then
			ASHelperMessage('Создан файл конфигурации.')
		end
    end
	while not sampIsLocalPlayerSpawned() do
		wait(200)
	end
	getmyrank = true
	ASHelperMessage(('SWAT Helper %s успешно загружен. Автор: Vilgot_Lausen'):format(thisScript().version))
	ASHelperMessage('Введите /swat или BB(чит-кодом), чтобы открыть настройки.')
	checkstyle()
	imgui.Process = false
	sampRegisterChatCommand('tempcmd',function()
		fastmenuID = 0
		windows.imgui_fm.v = true
		windowtype = 8
	end)
	if configuration.main_settings.changelog then
		windows.imgui_changelog.v = true
		configuration.main_settings.changelog = false
		inicfg.save(configuration, 'SWAT Helper.ini')
	end
	sampRegisterChatCommand('swat', function()
		windows.imgui_fm.v = false
		windows.imgui_sobes.v = false
		windows.imgui_settings.v = not windows.imgui_settings.v
		settingswindow = 0
	end)
	sampRegisterChatCommand('swatbind', function()
		choosedslot = nil
		windows.imgui_binder.v = not windows.imgui_binder.v
	end)
	sampRegisterChatCommand('swatrek', function()
		if configuration.main_settings.myrankint >= 0 then
			windows.imgui_lect.v = not windows.imgui_lect.v
			return
		end
		ASHelperMessage('Данная функция доступна с 5-го ранга.')
		return
	end)
	sampRegisterChatCommand('swatdep', function()
		if configuration.main_settings.myrankint >= 0 then
			windows.imgui_depart.v = not windows.imgui_depart.v
			return
		end
		ASHelperMessage('Данная функция доступна с 5-го ранга.')
		return
	end)
	
	sampRegisterChatCommand('uninvite', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local uvalid = param:match('(%d+)')
					local reason = select(2, param:match('(%d+) (.+),')) or select(2, param:match('(%d+) (.+)'))
					local withbl = select(2, param:match('(.+), (.+)'))
					local uvalid = tonumber(uvalid)
					if uvalid ~= nil and uvalid ~= '' and reason ~= nil and reason ~= '' then
						if uvalid ~= select(2,sampGetPlayerIdByCharHandle(playerPed)) then
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/time')
								sampSendChat('/me {gender:достал|достала} КПК из кармана')
								wait(2000)
								sampSendChat('/me {gender:перешёл|перешла} в раздел \'Увольнение\'')
								wait(2000)
								sampSendChat('/do Раздел открыт.')
								wait(2000)
								sampSendChat('/me {gender:внёс|внесла} человека в раздел \'Увольнение\'')
								wait(2000)
								if withbl then
									sampSendChat('/me {gender:перешёл|перешла} в раздел \'Чёрный список\'')
									wait(2000)
									sampSendChat('/me {gender:занёс|занесла} сотрудника в раздел, после чего {gender:подтвердил|подтвердила} изменения')
									wait(2000)
									sampSendChat('/do Изменения были сохранены.')
									wait(2000)
									sampSendChat(string.format('/uninvite %s %s',uvalid,reason))
									wait(2000)
									sampSendChat(string.format('/blacklist %s %s',uvalid,withbl))
								else
									sampSendChat('/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} КПК и {gender:положил|положила} его обратно в карман')
									wait(2000)
									sampSendChat(string.format('/uninvite %s %s',uvalid,reason))
								end
								sampSendChat('/time')
								inprocess = false
							end)
							return
						end
						ASHelperMessage('Вы не можете увольнять из организации самого себя.')
						return
					end
					ASHelperMessage('/uninvite [id] [причина], [причина чс] (не обязательно)')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/uninvite %s',param))
		return
	end)
	sampRegisterChatCommand('invite', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local id = param:match('(%d+)')
					local id = tonumber(id)
					if id ~= nil then
						if id ~= select(2,sampGetPlayerIdByCharHandle(playerPed)) then
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/do Ключи от шкафчика в кармане.')
								wait(2000)
								sampSendChat('/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика')
								wait(2000)
								sampSendChat('/me {gender:передал|передала} ключ человеку напротив')
								wait(2000)
								sampSendChat('Добро пожаловать! Раздевалка за дверью.')
								wait(2000)
								sampSendChat('Со всей информацией Вы можете ознакомиться на оф. портале.')
								wait(2000)								
								sampSendChat(string.format('/invite %s',id))
								inprocess = false
							end)
							return
						end
						ASHelperMessage('Вы не можете приглашать в организацию самого себя.')
						return
					end
					ASHelperMessage('/invite [id]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/invite %s',param))
		return
	end)
	sampRegisterChatCommand('giverankk', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local id,rank = param:match('(%d+) (%d)')
					local id = tonumber(id)
					local rank = tonumber(rank)
					if id ~= nil and id ~= '' and rank ~= nil and rank ~= '' then
						if id ~= select(2,sampGetPlayerIdByCharHandle(playerPed)) then
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/me {gender:включил|включила} КПК')
								wait(2000)
								sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
								wait(2000)
								sampSendChat('/me {gender:выбрал|выбрала} в разделе нужного сотрудника')
								wait(2000)
								sampSendChat('/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения')
								wait(2000)
								sampSendChat('/do Информация о сотруднике была изменена.')
								wait(2000)
								sampSendChat('Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.')
								wait(2000)								
								sampSendChat(string.format('/giverankk %s %s',id,rank))
								inprocess = false
							end)
							return
						end
						ASHelperMessage('Вы не можете менять ранг самому себе.')
						return
					end
					ASHelperMessage('/giverank [id] [ранг]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/giverankk %s',param))
		return
	end)
	sampRegisterChatCommand('blacklistt', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local id,reason = param:match('(%d+) (.+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' and reason ~= nil and reason ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/time')
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Чёрный список\'')
							wait(2000)
							sampSendChat('/me {gender:ввёл|ввела} имя нарушителя')
							wait(2000)
							sampSendChat('/me {gender:внёс|внесла} нарушителя в раздел \'Чёрный список\'')
							wait(2000)
							sampSendChat('/me {gender:подтведрдил|подтвердила} изменения')
							wait(2000)
							sampSendChat('/do Изменения были сохранены.')
							wait(2000)								
							sampSendChat(string.format('/blacklistt %s %s',id,reason))
							sampSendChat('/time')
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/blacklistt [id] [причина]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/blacklistt %s',param))
		return
	end)
	sampRegisterChatCommand('unblacklistt', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local id = param:match('(%d+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' then	
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Чёрный список\'')
							wait(2000)
							sampSendChat('/me {gender:ввёл|ввела} имя гражданина в поиск')
							wait(2000)
							sampSendChat('/me {gender:убрал|убрала} гражданина из раздела \'Чёрный список\'')
							wait(2000)
							sampSendChat('/me {gender:подтведрдил|подтвердила} изменения')
							wait(2000)
							sampSendChat('/do Изменения были сохранены.')
							wait(2000)								
							sampSendChat(string.format('/unblacklistt %s',id))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/unblacklistt [id]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/unblacklistt %s',param))
		return
	end)
	sampRegisterChatCommand('fwarnn', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local id,reason = param:match('(%d+) (.+)')
					if id ~= nil and id ~= '' and reason ~= nil and reason ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
							wait(2000)
							sampSendChat('/me {gender:зашёл|зашла} в раздел \'Выговоры\'')
							wait(2000)
							sampSendChat('/me найдя в разделе нужного сотрудника, {gender:добавил|добавила} в его личное дело выговор')
							wait(2000)
							sampSendChat('/do Выговор был добавлен в личное дело сотрудника.')
							wait(2000)
							sampSendChat(string.format('/fwarnn %s %s',id,reason))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/fwarnn [id] [причина]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/fwarnn %s',param))
		return
	end)
	sampRegisterChatCommand('unfwarnn', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local id = param:match('(%d+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
							wait(2000)
							sampSendChat('/me {gender:зашёл|зашла} в раздел \'Выговоры\'')
							wait(2000)
							sampSendChat('/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор')
							wait(2000)
							sampSendChat('/do Выговор был убран из личного дела сотрудника.')
							wait(2000)								
							sampSendChat(string.format('/unfwarnn %s',id))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/unfwarnn [id]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/unfwarnn %s',param))
		return
	end)
	sampRegisterChatCommand('fmutee', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local id,mutetime,reason = param:match('(%d+) (%d+) (.+)')
					local id = tonumber(id)
					local mutetime = tonumber(mutetime)	
					if id ~= nil and id ~= '' and reason ~= nil and reason ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:включил|включила} КПК')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками Автошколы\'')
							wait(2000)
							sampSendChat('/me {gender:выбрал|выбрала} нужного сотрудника')
							wait(2000)
							sampSendChat('/me {gender:выбрал|выбрала} пункт \'Отключить рацию сотрудника\'')
							wait(2000)
							sampSendChat('/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\'')
							wait(2000)							
							sampSendChat(string.format('/fmutee %s %s %s',id,mutetime,reason))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/fmutee [id] [время] [причина]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/fmutee %s',param))
		return
	end)
	sampRegisterChatCommand('funmutee', function(param)
		if configuration.main_settings.dorponcmd then		
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local id = param:match('(%d+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:включил|включила} КПК')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками Автошколы\'')
							wait(2000)
							sampSendChat('/me {gender:выбрал|выбрала} нужного сотрудника')
							wait(2000)
							sampSendChat('/me {gender:выбрал|выбрала} пункт \'Включить рацию сотрудника\'')
							wait(2000)
							sampSendChat('/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\'')
							wait(2000)							
							sampSendChat(string.format('/funmutee %s',id))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/funmutee [id]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/funmutee %s',param))
		return
	end)
	sampRegisterChatCommand('expelk', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 0 then
				if not inprocess then
					local id,reason = param:match('(%d+) (.+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' and reason ~= nil and reason ~= '' then
						if not sampIsPlayerPaused(id) then
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/do Рация свисает на поясе.')
								wait(2000)
								sampSendChat('/me сняв рацию с пояса, {gender:вызвал|вызвала} охрану по ней')
								wait(2000)
								sampSendChat('/do Охрана выводит нарушителя из холла.')
								wait(2000)									
								sampSendChat(string.format('/expelk %s %s',id,reason))
								inprocess = false
							end)
							return
						end
						ASHelperMessage('Игрок находится в АФК!')
						return
					end
					ASHelperMessage('/expelk [id] [причина]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 2-го ранга.')
			return
		end
		sampSendChat(string.format('/expelk %s',param))
		return
	end)
	updatechatcommands()
	local bindkeysthread = lua_thread.create_suspended(keybindactivation)

	-- меню быстрого доступа
	while true do
	if sampGetChatInputText() == '!строй' then
			sampSetChatInputText(configuration.main_settings.forma_post)
		end
if testCheat('BB') then
windows.imgui_fm.v = false
		windows.imgui_sobes.v = false
		windows.imgui_settings.v = not windows.imgui_settings.v
		settingswindow = 0
	    end
		if getCharPlayerIsTargeting() then
			if configuration.main_settings.createmarker then
				local targettingped = select(2,getCharPlayerIsTargeting())
				if sampGetPlayerIdByCharHandle(targettingped) then
					if marker ~= nil and oldtargettingped ~= targettingped then
						removeBlip(marker)
						marker = nil
						marker = addBlipForChar(targettingped)
					elseif marker == nil and oldtargettingped ~= targettingped then
						marker = addBlipForChar(targettingped)
					end
				end
				oldtargettingped = targettingped
			end
			if wasKeyPressed(vkeys.name_to_id(configuration.main_settings.usefastmenu,true)) then
				if not sampIsChatInputActive() then
					if sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())) then
						setVirtualKeyDown(0x02,false)
						fastmenuID = select(2,sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())))
						local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
						ASHelperMessage(string.format('Вы использовали меню быстрого доступа на: %s [%s]',string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' '),fastmenuID))
						ASHelperMessage(string.format('Зажмите {%06X}ALT{FFFFFF} для того, чтобы скрыть курсор. {%06X}ESC{FFFFFF} для того, чтобы закрыть меню.', join_rgb(r, g, b), join_rgb(r, g, b)))
						wait(0)
						windowtype = 0
						windows.imgui_fm.v = true
					end
				end
			end
		end
		
		
		-- всё, что связано с imgui
		if windows.imgui_settings.v or windows.imgui_fm.v or windows.imgui_binder.v or windows.imgui_sobes.v or windows.imgui_lect.v or windows.imgui_depart.v or windows.imgui_changelog.v then
			if isKeyDown(0x12) and not setbinderkey then
				imgui.ShowCursor = false
			else
				imgui.ShowCursor = true
			end
			imgui.Process = true
		elseif windows.imgui_stats.v then
			imgui.Process = true
			imgui.ShowCursor = false
		else
			imgui.ShowCursor = false
			imgui.Process = false
		end
		-- кнопки биндера
		for key, value in pairs(configuration.BindsName) do
			if tostring(value) == tostring(configuration.BindsName[key]) then
				if configuration.BindsKeys[key] ~= '' then
					if tostring(configuration.BindsKeys[key]):match('(.+) %p (.+)') then
						local fkey = tostring(configuration.BindsKeys[key]):match('(.+) %p')
						local skey = tostring(configuration.BindsKeys[key]):match('%p (.+)')
						if isKeyDown(vkeys.name_to_id(fkey)) and wasKeyPressed(vkeys.name_to_id(skey)) and not sampIsChatInputActive() then
							if not inprocess then
								bindkeysthread:run(key)
							else
								ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
							end
						end
					elseif tostring(configuration.BindsKeys[key]):match('(.+)') then
						local fkey = tostring(configuration.BindsKeys[key]):match('(.+)')
						if wasKeyPressed(vkeys.name_to_id(fkey)) and not sampIsChatInputActive() then
							if not inprocess then
								bindkeysthread:run(key)
							else
								ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
							end
						end
					end
				end
			end
		end
		wait(0)
	end
end

if bNotf then
	notf.addNotification(("Главное меню: /swat, BB\nВзаимодействие: ПКМ + E"), 4, 3)
	notf.addNotification(("Скрипт 1.1 для SWAT успешно запущен!"), 4, 3)
end

function updatechatcommands()
	for key, value in pairs(configuration.BindsName) do
		if tostring(value) == tostring(configuration.BindsName[key]) then
			if configuration.BindsCmd[key] ~= '' then
				sampUnregisterChatCommand(configuration.BindsCmd[key])
				sampRegisterChatCommand(configuration.BindsCmd[key], function()
					if not inprocess then
						local temp = 0
						local temp2 = 0
						for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
							temp = temp + 1
						end
						lua_thread.create(function()
							inprocess = true
							for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
								temp2 = temp2 + 1
								sampSendChat(tostring(bp))
								if temp2 ~= temp then
									wait(configuration.BindsDelay[key])
								end
							end
							inprocess = false
						end)
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end)
			end
		end
	end
end

if sampevcheck then
	function sampev.onCreatePickup(id, model, pickupType, position)
		if model == 19132 and getCharActiveInterior(playerPed) == 14 then
			return {id, 1272, pickupType, position}
		end
	end

	function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
		if dialogId == 6 and givelic then
			

		elseif dialogId == 235 and getmyrank then
			if text:find('Полиция ЛВ') then
				for DialogLine in text:gmatch('[^\r\n]+') do
					local nameRankStats, getStatsRank = DialogLine:match('Должность: {B83434}(.+)%p(%d+)%p')
					if tonumber(getStatsRank) then
						local rangint = tonumber(getStatsRank)
						local rang = nameRankStats
						if rangint ~= configuration.main_settings.myrankint then
							ASHelperMessage("Ваш ранг был обновлён на "..rang.." ("..rangint..")")
						end
						configuration.main_settings.myrank = rang
						configuration.main_settings.myrankint = rangint
						if nameRankStats:find('Упраляющий') or devmaxrankp then
							getStatsRank = 10
							configuration.main_settings.myrank = "Упраляющий"
							configuration.main_settings.myrankint = 10
						end
						inicfg.save(configuration,"SWAT Helper")
					end
				end
			
			end
			getmyrank = false
			return false

		elseif dialogId == 1234 then
			if text:find('Срок дейспыфптвия') then
				if not mcvalue then
					if text:find("Ипыфмя: "..sampGetPlayerNickname(fastmenuID)) then
						for DialogLine in text:gmatch('[^\r\n]+') do
							if text:find("Полностью здоровый") then
							local statusint = DialogLine:match('{CEAD2A}Наркозаваыфисимость: (%d+)')
								if tonumber(statusint) then
									statusint = tonumber(statusint)
									if statusint <= 10000 then
										mcvalue = true
										mcverdict = ("в порядке")
									else
										mcvalue = true
										mcverdict = ("наркозависимость")
									end
								end
							else
								mcvalue = true
								mcverdict = ("не полностью здоровый")
							end
						end
					end
				end
				
			elseif text:find('Серия') then
				if not passvalue then
					for DialogLine in text:gmatch('[^\r\n]+') do
						if text:find("Имя: {FFD700}"..sampGetPlayerNickname(fastmenuID)) then
							if not text:find('{FFFFFF}Организация:') then
								for DialogLine in text:gmatch('[^\r\n]+') do
									local passstatusint = DialogLine:match('{FFFFFF}Лет в штате: {FFD700}(%d+)')
									if tonumber(passstatusint) then
										if tonumber(passstatusint) >= 3 then
											for DialogLine in text:gmatch('[^\r\n]+') do
												local zakonstatusint = DialogLine:match('{FFFFFF}Законопослушность: {FFD700}(%d+)')
												if tonumber(zakonstatusint) then
													if tonumber(zakonstatusint) >= 35 then
														if not text:find('Лечился в Психиатрической больнице') then
															if not text:find('Состоит в ЧС{FF6200} Полиция ЛВ') then
																if not text:find("Warns") then
																	passvalue = true
																	passverdict = ("в порядке")
																else
																	passvalue = true
																	passverdict = ("есть варны")
																end
															else
																passvalue = true
																passverdict = ("в чс")
															end
														else
															passvalue = true
															passverdict = ("был в деморгане")
														end
													else
														passvalue = true
														passverdict = ("не законопослушный")
													end
												end
											end
										else
											passvalue = true
											passverdict = ("меньше 3 лет в штате")
										end
									end
								end
							else
								passvalue = true
								passverdict = ("игрок в организации")
							end
						end
					end
				end
			end
		end
	end
	
	function sampev.onServerMessage(color, message)
		if configuration.main_settings.replacechat then
		end
		if message == ('Используйте: /jobprogress(Без параметра)') and color == -1104335361 then
			sampSendChat('/jobprogress')
			return false
		end
		if message:find('%[R%]') and not message:find('%[Объявление%]') and color == 766526463 then
			local r, g, b, a = imgui.ImColor(configuration.main_settings.RChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message}
		end
		if message:find('%[D%]') and color == 865730559 or color == 865665023 then
			if message:find(u8:decode(departsettings.myorgname.v)) then
				local tmsg = message:gsub('%[D%] ','')
				table.insert(dephistory,tmsg)
			end
			local r, g, b, a = imgui.ImColor(configuration.main_settings.DChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message }
		end
		if message:find('повысил до') then
			getmyrank = true
			sampSendChat('/stats')
		end
		if message:find('Приветствуем нового члена нашей организации') then
			sampSendChat('/r В нашей компашке новый сотрудник! Поздравляем его и желаем удачи.', -1)
		end
		if message:find('Приветствуем нового члена нашей организации (.+), которого пригласил: (.+)') then
			local invited,inviting = message:match('Приветствуем нового члена нашей организации (.+), которого пригласил: (.+)%[')
			if inviting == sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) then
				if invited == sampGetPlayerNickname(waitingaccept) then
				end
			end
			return {color,message}
		end
	end
	
	
	
	function sampev.onSendChat(message)
		if message:find('{my_id}') then
			sampSendChat(message:gsub('{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
			return false
		end
		if message:find('{my_name}') then
			sampSendChat(message:gsub('{my_name}', (configuration.main_settings.useservername and string.gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname))))
			return false
		end
		if message:find('{my_rank}') then
			sampSendChat(message:gsub('{my_rank}', configuration.main_settings.myrank))
			return false
		end
		if message:find('{my_score}') then
			sampSendChat(message:gsub('{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
			return false
		end
		if message:find('{H}') then
			sampSendChat(message:gsub('{H}', os.date('%H', os.time())))
			return false
		end
		if message:find('{HM}') then
			sampSendChat(message:gsub('{HM}', os.date('%H:%M', os.time())))
			return false
		end
		if message:find('{HMS}') then
			sampSendChat(message:gsub('{HMS}', os.date('%H:%M:%S', os.time())))
			return false
		end
		if message:find('{close_id}') then
			if select(1,getClosestPlayerId()) then
				sampSendChat(message:gsub('{close_id}', select(2,getClosestPlayerId())))
				return false
			end
			ASHelperMessage('В зоне стрима не найдено ни одного игрока')
			return false
		end
		if message:find('@{%d+}') then
			local id = message:match('@{(%d+)}')
			if id and sampIsPlayerConnected(id) then
				sampSendChat(message:gsub('@{%d+}', sampGetPlayerNickname(id)))
				return false
			end
			ASHelperMessage('Такого игрока нет на сервере.')
			return false
		end
		if message:find('{gender:%A+|%A+}') then
			local male, female = message:match('{gender:(%A+)|(%A+)}')
			if configuration.main_settings.gender == 0 then
				local gendermsg = message:gsub('{gender:%A+|%A+}', male, 1)
				sampSendChat(tostring(gendermsg))
				return false
			else
				local gendermsg = message:gsub('{gender:%A+|%A+}', female, 1)
				sampSendChat(tostring(gendermsg))
				return false
			end
		end
		--на основе https://www.blast.hk/threads/43610/
		if configuration.main_settings.useaccent and configuration.main_settings.myaccent ~= '' and configuration.main_settings.myaccent ~= ' ' then
			if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == 'q' or message == ';)' then
				return{message}
			end
			if string.find(u8:decode(configuration.main_settings.myaccent), 'акцент') or string.find(u8:decode(configuration.main_settings.myaccent), 'Акцент') then
				return{('[%s]: %s'):format(u8:decode(configuration.main_settings.myaccent),message)}
			else
				return{('[%s акцент]: %s'):format(u8:decode(configuration.main_settings.myaccent),message)}
			end
		end
	end
	
	function sampev.onSendCommand(cmd)
		if cmd:find('{my_id}') then
			sampSendChat(cmd:gsub('{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
			return  false
		end
		if cmd:find('{my_name}') then
			sampSendChat(cmd:gsub('{my_name}', (configuration.main_settings.useservername and string.gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname))))
			return false
		end
		if cmd:find('{my_rank}') then
			sampSendChat(cmd:gsub('{my_rank}', configuration.main_settings.myrank))
			return false
		end
		if cmd:find('{my_score}') then
			sampSendChat(cmd:gsub('{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
			return false
		end
		if cmd:find('{H}') then
			sampSendChat(cmd:gsub('{H}', os.date('%H', os.time())))
			return false
		end
		if cmd:find('{HM}') then
			sampSendChat(cmd:gsub('{HM}', os.date('%H:%M', os.time())))
			return false
		end
		if cmd:find('{HMS}') then
			sampSendChat(cmd:gsub('{HMS}', os.date('%H:%M:%S', os.time())))
			return false
		end
		if cmd:find('{close_id}') then
			if select(1,getClosestPlayerId()) then
				sampSendChat(cmd:gsub('{close_id}', select(2,getClosestPlayerId())))
				return false
			end
			ASHelperMessage('В зоне стрима не найдено ни одного игрока')
			return false
		end
		if cmd:find('@{%d+}') then
			local id = cmd:match('@{(%d+)}')
			if id and sampIsPlayerConnected(id) then
				sampSendChat(cmd:gsub('@{%d+}', sampGetPlayerNickname(id)))
				return false
			end
			ASHelperMessage('Такого игрока нет на сервере.')
			return false
		end
		if cmd:find('{gender:%A+|%A+}') then
			local male, female = cmd:match('{gender:(%A+)|(%A+)}')
			if configuration.main_settings.gender == 0 then
				local gendermsg = cmd:gsub('{gender:%A+|%A+}', male, 1)
				sampSendChat(tostring(gendermsg))
				return false
			else
				local gendermsg = cmd:gsub('{gender:%A+|%A+}', female, 1)
				sampSendChat(tostring(gendermsg))
				return false
			end
		end
	end
	
	function sampev.onSendSpawn()
		lua_thread.create(function()
			wait(1000)
			getmyrank = true
			sampSendChat('/stats')
		end)
	end
end


function ASHelperMessage(text)
	if imguicheck then
		local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
		sampAddChatMessage(('[SWAT-Helper]{EBEBEB} %s'):format(text),join_rgb(r, g, b))
	else
		sampAddChatMessage(('[SWAT-Helper]{EBEBEB} %s'):format(text),0xff6633)
	end
end

if imguicheck then
	function onWindowMessage(msg, wparam, lparam)
		if wparam == 0x1B and not isPauseMenuActive() then
			if windows.imgui_settings.v or windows.imgui_fm.v or windows.imgui_binder.v or windows.imgui_sobes.v or windows.imgui_lect.v or windows.imgui_depart.v or windows.imgui_changelog.v then
				consumeWindowMessage(true, false)
				if(msg == 0x101)then
					windows.imgui_settings.v = false
					windows.imgui_fm.v = false
					windows.imgui_sobes.v = false
					windows.imgui_lect.v = false
					windows.imgui_binder.v = false
					windows.imgui_depart.v = false
					windows.imgui_changelog.v = false
					imgui.ShowCursor = false
				end
			end
		end
	end
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8)) 
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function join_rgb(rr, gg, bb)
	return bit.bor(bit.bor(bb, bit.lshift(gg, 8)), bit.lshift(rr, 16))
end

function onQuitGame()
	inicfg.save(configuration, 'SWAT Helper.ini')
end


if imguicheck and encodingcheck then
	u8 									= encoding.UTF8
	encoding.default 					= 'CP1251'

	local StyleBox_select				= imgui.ImInt(configuration.main_settings.style)
	local StyleBox_arr					= {u8'Тёмно-оранжевая (transp.)',u8'Тёмно-красная (not transp.)',u8'Светло-синяя (not transp.)',u8'Фиолетовая (not transp.)',u8'Тёмно-зеленая (not transp.)'}

	local Ranks_select 					= imgui.ImInt(0)
	local Ranks_arr 					= {u8'[1] Стажёр',u8'[2] Практикант',u8'[3] Сержант',u8'[4] Мл. Оперативник',u8'[5] Оперативник',u8'[6] Офицер первого звена',u8'[7] Лейтенант',u8'[8] Командор',u8'[9] Заместитель Директора'}
	
	local sobesdecline_select 			= imgui.ImInt(0)
	local sobesdecline_arr 				= {u8'варн',u8'ЧС',u8'нРП ник',u8'Отсутствует военник',u8'Отсутствует уровень',u8'Отсутствует законка',u8'Проф.непригоден'}
		
	local uninvitebuf 					= imgui.ImBuffer(256)
	local blacklistbuf 					= imgui.ImBuffer(256)
	local uninvitebox 					= imgui.ImBool(false)
	local forma_post        = imgui.ImBuffer(u8(configuration.main_settings.forma_post), 256)
	local blacklistbuff 				= imgui.ImBuffer(256)

	local fwarnbuff 					= imgui.ImBuffer(256)
	
	local fmutebuff 					= imgui.ImBuffer(256)
	local fmuteint 						= imgui.ImInt(0)

	local buttons 						= {fa.ICON_FA_USER_COG..u8' Настройки пользователя',fa.ICON_FA_FILE_ALT..u8' Тренировки',fa.ICON_FA_KEYBOARD..u8' Горячие клавиши',fa.ICON_FA_BOOK_OPEN..u8' Меню семьи',fa.ICON_FA_PALETTE..u8' Настройки цветов',fa.ICON_FA_BOOK_OPEN..u8' Правила, шпоры',fa.ICON_FA_INFO_CIRCLE..u8' Информация о скрипте'}

	local search_rule				 	= imgui.ImBuffer(256)
	local rule_align					= imgui.ImInt(configuration.main_settings.rule_align)
	
	local lastq = false

	windows = {
		imgui_settings 					= imgui.ImBool(false),
		imgui_fm 						= imgui.ImBool(false),
		imgui_sobes						= imgui.ImBool(false),
		imgui_binder 					= imgui.ImBool(false),
		imgui_stats						= imgui.ImBool(false),
		imgui_lect						= imgui.ImBool(false),
		imgui_depart					= imgui.ImBool(false),
		imgui_changelog					= imgui.ImBool(configuration.main_settings.changelog)
	}
	
	local bindersettings = {
		binderbuff 						= imgui.ImBuffer(4096),
		bindername 						= imgui.ImBuffer(40),
		binderdelay 					= imgui.ImBuffer(7),
		bindertype 						= imgui.ImInt(0),
		bindercmd 						= imgui.ImBuffer(15)
	}
	
	local chatcolors = {
		RChatColor 						= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.RChatColor):GetFloat4()),
		DChatColor 						= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.DChatColor):GetFloat4()),
		ASChatColor 					= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.ASChatColor):GetFloat4())
	}
	
	local usersettings = {
		useaccent 						= imgui.ImBool(configuration.main_settings.useaccent),
		createmarker 					= imgui.ImBool(configuration.main_settings.createmarker),
		useservername 					= imgui.ImBool(configuration.main_settings.useservername),
		dorponcmd						= imgui.ImBool(configuration.main_settings.dorponcmd),
		replacechat						= imgui.ImBool(configuration.main_settings.replacechat),
		noscrollbar						= imgui.ImBool(configuration.main_settings.noscrollbar),
		playdubinka						= imgui.ImBool(configuration.main_settings.playdubinka),
		myname 							= imgui.ImBuffer(configuration.main_settings.myname, 256),
		myaccent 						= imgui.ImBuffer(configuration.main_settings.myaccent, 256),
		gender 							= imgui.ImInt(configuration.main_settings.gender),
	}
	
	
	local lectionsettings = {
		lection_type					= imgui.ImInt(1),
		lection_delay					= imgui.ImInt(configuration.main_settings.lection_delay),
		lection_name					= imgui.ImBuffer(256),
		lection_text					= imgui.ImBuffer(65536)
	}

	departsettings = {
		myorgname						= imgui.ImBuffer(u8(configuration.main_settings.astag),50),
		toorgname						= imgui.ImBuffer(50),
		frequency						= imgui.ImBuffer(7),
		myorgtext						= imgui.ImBuffer(256),
	}

	local questionsettings = {
		questionname					= imgui.ImBuffer(256),
		questionhint					= imgui.ImBuffer(256),
		questionques					= imgui.ImBuffer(256)
	}
	
	local whiteashelper					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\settingswhite.png')
	local blackashelper					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\settingsblack.png')
	local whitebinder					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\binderwhite.png')
	local blackbinder					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\binderblack.png')
	local whitelection					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\lectionwhite.png')
	local blacklection					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\lectionblack.png')
	local whitedepart					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\departamenwhite.png')
	local blackdepart					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\departamentblack.png')
	local whitechangelog				= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\changelogwhite.png')
	local blackchangelog				= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\SWAT Helper\\Images\\changelogblack.png')
	
	local tagbuttons = {
		{name = '{my_id}',text = 'Пишет Ваш ID.',hint = '/n /showpass {my_id}\n(( /showpass \'Ваш ID\' ))'},
		{name = '{my_name}',text = 'Пишет Ваш ник из настроек.',hint = 'Здравствуйте, я {my_name}\n- Здравствуйте, я '..u8:decode(configuration.main_settings.myname)..'.'},
		{name = '{my_rank}',text = 'Пишет Ваш ранг из настроек.',hint = '/do На груди бейджик {my_rank}\nНа груди бейджик '..configuration.main_settings.myrank},
		{name = '{my_score}',text = 'Пишет Ваш уровень.',hint = 'Я проживаю в штате уже {my_score} лет!\n- Я проживаю в штате уже \'Ваш уровень\' лет!'},
		{name = '{H}',text = 'Пишет системное время в часы.',hint = 'Давай встретимся завтра тут же в {H} \n- Давай встретимся завтра тут же в чч'},
		{name = '{HM}',text = 'Пишет системное время в часы:минуты.',hint = 'Сегодня в {HM} будет концерт!\n- Сегодня в чч:мм будет концерт!'},
		{name = '{HMS}',text = 'Пишет системное время в часы:минуты:секунды.',hint = 'У меня на часах {HMS}\n- У меня на часах \'чч:мм:сс\''},
		{name = '{gender:Текст1|Текст2}',text = 'Пишет сообщение в зависимости от вашего пола.',hint = 'Я вчера {gender:был|была} в банке\n- Если мужской пол: был в банке\n- Если женский пол: была в банке'},
		{name = '@{ID}',text = 'Узнаёт имя игрока по ID.',hint = 'Ты не видел где сейчас @{43}?\n- Ты не видел где сейчас \'Имя 43 ида\''},
		{name = '{close_id}',text = 'Узнаёт ID ближайшего к вам игрока',hint = 'О, а вот и @{{close_id}}?\nО, а вот и \'Имя ближайшего ида\''},
	}

	local fa_glyph_ranges	= imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
	function imgui.BeforeDrawFrame()
		if fa_font == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = true
			fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
		end
		if fontsize16 == nil then fontsize16 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\trebucbd.ttf', 16.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end
		if fontsize25 == nil then fontsize25 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\trebucbd.ttf', 25.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end
	end

	function checkstyle()
		imgui.SwitchContext()
		local style 							= imgui.GetStyle()
		local colors 							= style.Colors
		local clr 								= imgui.Col
		local ImVec4 							= imgui.ImVec4
		local ImVec2 							= imgui.ImVec2

		style.WindowTitleAlign 					= ImVec2(0.5, 0.5)
		style.WindowPadding 					= ImVec2(15, 15)
		style.WindowRounding 					= 6.0
		style.FramePadding 						= ImVec2(5, 5)
		style.FrameRounding 					= 5.0
		style.ItemSpacing						= ImVec2(12, 8)
		style.ItemInnerSpacing 					= ImVec2(8, 6)
		style.IndentSpacing 					= 25.0
		style.ScrollbarSize 					= 15
		style.ScrollbarRounding 				= 9.0
		style.GrabMinSize 						= 5.0
		style.GrabRounding 						= 3.0
		style.ChildWindowRounding 				= 5.0
		if configuration.main_settings.style == 0 or configuration.main_settings.style == nil then -- на основе https://www.blast.hk/threads/25442/post-310168
			colors[clr.Text] 					= ImVec4(0.80, 0.80, 0.83, 1.00)
			colors[clr.TextDisabled] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
			colors[clr.WindowBg] 				= ImVec4(0.06, 0.05, 0.07, 0.95)
			colors[clr.ChildWindowBg] 			= ImVec4(0.10, 0.09, 0.12, 0.50)
			colors[clr.PopupBg] 				= ImVec4(0.07, 0.07, 0.09, 1.00)
			colors[clr.Border] 					= ImVec4(0.40, 0.40, 0.53, 0.18)
			colors[clr.BorderShadow] 			= ImVec4(0.92, 0.91, 0.88, 0.00)
			colors[clr.FrameBg] 				= ImVec4(0.15, 0.14, 0.16, 0.50)
			colors[clr.FrameBgHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
			colors[clr.FrameBgActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.TitleBg] 				= ImVec4(0.76, 0.31, 0.00, 1.00)
			colors[clr.TitleBgCollapsed] 		= ImVec4(1.00, 0.98, 0.95, 0.75)
			colors[clr.TitleBgActive] 			= ImVec4(0.80, 0.33, 0.00, 1.00)
			colors[clr.MenuBarBg] 				= ImVec4(0.10, 0.09, 0.12, 1.00)
			colors[clr.ScrollbarBg] 			= ImVec4(0.10, 0.09, 0.12, 1.00)
			colors[clr.ScrollbarGrab] 			= ImVec4(0.80, 0.80, 0.83, 0.31)
			colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.ScrollbarGrabActive] 	= ImVec4(0.06, 0.05, 0.07, 1.00)
			colors[clr.ComboBg] 				= ImVec4(0.19, 0.18, 0.21, 1.00)
			colors[clr.CheckMark] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
			colors[clr.SliderGrab] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
			colors[clr.SliderGrabActive] 		= ImVec4(1.00, 0.42, 0.00, 1.00)
			colors[clr.Button] 					= ImVec4(0.15, 0.14, 0.21, 0.60)
			colors[clr.ButtonHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
			colors[clr.ButtonActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.Header] 					= ImVec4(0.10, 0.09, 0.12, 1.00)
			colors[clr.HeaderHovered] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.HeaderActive] 			= ImVec4(0.06, 0.05, 0.07, 1.00)
			colors[clr.ResizeGrip] 				= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.ResizeGripHovered] 		= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.ResizeGripActive] 		= ImVec4(0.06, 0.05, 0.07, 1.00)
			colors[clr.CloseButton] 			= ImVec4(0.91, 0.44, 0.00, 1.00)
			colors[clr.CloseButtonHovered] 		= ImVec4(0.40, 0.39, 0.38, 0.39)
			colors[clr.CloseButtonActive] 		= ImVec4(0.40, 0.39, 0.38, 1.00)
			colors[clr.PlotLines] 				= ImVec4(0.40, 0.39, 0.38, 0.63)
			colors[clr.PlotLinesHovered]		= ImVec4(0.25, 1.00, 0.00, 1.00)
			colors[clr.PlotHistogram] 			= ImVec4(0.40, 0.39, 0.38, 0.63)
			colors[clr.PlotHistogramHovered] 	= ImVec4(0.25, 1.00, 0.00, 1.00)
			colors[clr.TextSelectedBg] 			= ImVec4(0.25, 1.00, 0.00, 0.43)
			colors[clr.ModalWindowDarkening] 	= ImVec4(0.00, 0.00, 0.00, 0.30)
			--textcolorinhex						= '{ccccd4}'
		elseif configuration.main_settings.style == 1 then 
			colors[clr.Text]                   	= ImVec4(0.95, 0.96, 0.98, 1.00)
			colors[clr.TextDisabled]           	= ImVec4(0.29, 0.29, 0.29, 1.00)
			colors[clr.WindowBg]               	= ImVec4(0.14, 0.14, 0.14, 1.00)
			colors[clr.ChildWindowBg]          	= ImVec4(0.14, 0.14, 0.14, 1.00)
			colors[clr.PopupBg]                	= ImVec4(0.14, 0.14, 0.14, 1.00)
			colors[clr.Border]                 	= ImVec4(1.00, 0.28, 0.28, 0.50)
			colors[clr.BorderShadow]           	= ImVec4(1.00, 1.00, 1.00, 0.00)
			colors[clr.FrameBg]                	= ImVec4(0.22, 0.22, 0.22, 1.00)
			colors[clr.FrameBgHovered]         	= ImVec4(0.18, 0.18, 0.18, 1.00)
			colors[clr.FrameBgActive]          	= ImVec4(0.09, 0.12, 0.14, 1.00)
			colors[clr.TitleBg]                	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.TitleBgActive]          	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.TitleBgCollapsed]       	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.MenuBarBg]              	= ImVec4(0.20, 0.20, 0.20, 1.00)
			colors[clr.ScrollbarBg]            	= ImVec4(0.02, 0.02, 0.02, 0.39)
			colors[clr.ScrollbarGrab]          	= ImVec4(0.36, 0.36, 0.36, 1.00)
			colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.18, 0.22, 0.25, 1.00)
			colors[clr.ScrollbarGrabActive]    	= ImVec4(0.24, 0.24, 0.24, 1.00)
			colors[clr.ComboBg]                	= ImVec4(0.24, 0.24, 0.24, 1.00)
			colors[clr.CheckMark]              	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.SliderGrab]             	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.SliderGrabActive]       	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.Button]                 	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.ButtonHovered]          	= ImVec4(1.00, 0.25, 0.25, 1.00)
			colors[clr.ButtonActive]           	= ImVec4(1.00, 0.20, 0.20, 1.00)
			colors[clr.Header]                 	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.HeaderHovered]          	= ImVec4(1.00, 0.39, 0.39, 1.00)
			colors[clr.HeaderActive]           	= ImVec4(1.00, 0.21, 0.21, 1.00)
			colors[clr.ResizeGrip]             	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.ResizeGripHovered]      	= ImVec4(1.00, 0.39, 0.39, 1.00)
			colors[clr.ResizeGripActive]       	= ImVec4(1.00, 0.19, 0.19, 1.00)
			colors[clr.CloseButton]            	= ImVec4(1.00, 0.00, 0.00, 0.50)
			colors[clr.CloseButtonHovered]     	= ImVec4(1.00, 0.00, 0.00, 0.60)
			colors[clr.CloseButtonActive]      	= ImVec4(1.00, 0.00, 0.00, 0.70)
			colors[clr.PlotLines]              	= ImVec4(0.61, 0.61, 0.61, 1.00)
			colors[clr.PlotLinesHovered]       	= ImVec4(1.00, 0.43, 0.35, 1.00)
			colors[clr.PlotHistogram]          	= ImVec4(1.00, 0.21, 0.21, 1.00)
			colors[clr.PlotHistogramHovered]   	= ImVec4(1.00, 0.18, 0.18, 1.00)
			colors[clr.TextSelectedBg]         	= ImVec4(1.00, 0.25, 0.25, 1.00)
			colors[clr.ModalWindowDarkening]   	= ImVec4(0.00, 0.00, 0.00, 0.30)
			--textcolorinhex						= '{f2f5fa}'
		elseif configuration.main_settings.style == 2 then 
			colors[clr.Text]					= ImVec4(0.00, 0.00, 0.00, 0.51)
			colors[clr.TextDisabled]   			= ImVec4(0.24, 0.24, 0.24, 1.00)
			colors[clr.WindowBg]				= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.ChildWindowBg]        	= ImVec4(0.96, 0.96, 0.96, 1.00)
			colors[clr.PopupBg]              	= ImVec4(0.92, 0.92, 0.92, 1.00)
			colors[clr.Border]               	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.BorderShadow]         	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg]              	= ImVec4(0.68, 0.68, 0.68, 0.50)
			colors[clr.FrameBgHovered]       	= ImVec4(0.82, 0.82, 0.82, 1.00)
			colors[clr.FrameBgActive]        	= ImVec4(0.76, 0.76, 0.76, 1.00)
			colors[clr.TitleBg]              	= ImVec4(0.00, 0.45, 1.00, 0.82)
			colors[clr.TitleBgCollapsed]     	= ImVec4(0.00, 0.45, 1.00, 0.82)
			colors[clr.TitleBgActive]        	= ImVec4(0.00, 0.45, 1.00, 0.82)
			colors[clr.MenuBarBg]            	= ImVec4(0.00, 0.37, 0.78, 1.00)
			colors[clr.ScrollbarBg]          	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.ScrollbarGrab]        	= ImVec4(0.00, 0.35, 1.00, 0.78)
			colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.00, 0.33, 1.00, 0.84)
			colors[clr.ScrollbarGrabActive]  	= ImVec4(0.00, 0.31, 1.00, 0.88)
			colors[clr.ComboBg]              	= ImVec4(0.92, 0.92, 0.92, 1.00)
			colors[clr.CheckMark]            	= ImVec4(0.00, 0.49, 1.00, 0.59)
			colors[clr.SliderGrab]           	= ImVec4(0.00, 0.49, 1.00, 0.59)
			colors[clr.SliderGrabActive]     	= ImVec4(0.00, 0.39, 1.00, 0.71)
			colors[clr.Button]               	= ImVec4(0.00, 0.49, 1.00, 0.59)
			colors[clr.ButtonHovered]        	= ImVec4(0.00, 0.49, 1.00, 0.71)
			colors[clr.ButtonActive]         	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.Header]               	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.HeaderHovered]        	= ImVec4(0.00, 0.49, 1.00, 0.71)
			colors[clr.HeaderActive]         	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.ResizeGrip]           	= ImVec4(0.00, 0.39, 1.00, 0.59)
			colors[clr.ResizeGripHovered]    	= ImVec4(0.00, 0.27, 1.00, 0.59)
			colors[clr.ResizeGripActive]     	= ImVec4(0.00, 0.25, 1.00, 0.63)
			colors[clr.CloseButton]          	= ImVec4(0.00, 0.35, 0.96, 0.71)
			colors[clr.CloseButtonHovered]   	= ImVec4(0.00, 0.31, 0.88, 0.69)
			colors[clr.CloseButtonActive]    	= ImVec4(0.00, 0.25, 0.88, 0.67)
			colors[clr.PlotLines]            	= ImVec4(0.00, 0.39, 1.00, 0.75)
			colors[clr.PlotLinesHovered]     	= ImVec4(0.00, 0.39, 1.00, 0.75)
			colors[clr.PlotHistogram]        	= ImVec4(0.00, 0.39, 1.00, 0.75)
			colors[clr.PlotHistogramHovered] 	= ImVec4(0.00, 0.35, 0.92, 0.78)
			colors[clr.TextSelectedBg]       	= ImVec4(0.00, 0.47, 1.00, 0.59)
			colors[clr.ModalWindowDarkening] 	= ImVec4(0.20, 0.20, 0.20, 0.35)
			--textcolorinhex						= '{7d7d7d}'
		elseif configuration.main_settings.style == 3 then 
			colors[clr.Text]					= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.WindowBg]              	= ImVec4(0.14, 0.12, 0.16, 1.00)
			colors[clr.ChildWindowBg]         	= ImVec4(0.30, 0.20, 0.39, 0.00)
			colors[clr.PopupBg]               	= ImVec4(0.05, 0.05, 0.10, 0.90)
			colors[clr.Border]                	= ImVec4(0.89, 0.85, 0.92, 0.30)
			colors[clr.BorderShadow]          	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg]               	= ImVec4(0.30, 0.20, 0.39, 1.00)
			colors[clr.FrameBgHovered]        	= ImVec4(0.41, 0.19, 0.63, 0.68)
			colors[clr.FrameBgActive]         	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.TitleBg]               	= ImVec4(0.41, 0.19, 0.63, 0.45)
			colors[clr.TitleBgCollapsed]      	= ImVec4(0.41, 0.19, 0.63, 0.35)
			colors[clr.TitleBgActive]         	= ImVec4(0.41, 0.19, 0.63, 0.78)
			colors[clr.MenuBarBg]             	= ImVec4(0.30, 0.20, 0.39, 0.57)
			colors[clr.ScrollbarBg]           	= ImVec4(0.30, 0.20, 0.39, 1.00)
			colors[clr.ScrollbarGrab]         	= ImVec4(0.41, 0.19, 0.63, 0.31)
			colors[clr.ScrollbarGrabHovered]  	= ImVec4(0.41, 0.19, 0.63, 0.78)
			colors[clr.ScrollbarGrabActive]   	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.ComboBg]               	= ImVec4(0.30, 0.20, 0.39, 1.00)
			colors[clr.CheckMark]             	= ImVec4(0.56, 0.61, 1.00, 1.00)
			colors[clr.SliderGrab]            	= ImVec4(0.41, 0.19, 0.63, 0.24)
			colors[clr.SliderGrabActive]      	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.Button]                	= ImVec4(0.41, 0.19, 0.63, 0.44)
			colors[clr.ButtonHovered]         	= ImVec4(0.41, 0.19, 0.63, 0.86)
			colors[clr.ButtonActive]          	= ImVec4(0.64, 0.33, 0.94, 1.00)
			colors[clr.Header]                	= ImVec4(0.41, 0.19, 0.63, 0.76)
			colors[clr.HeaderHovered]         	= ImVec4(0.41, 0.19, 0.63, 0.86)
			colors[clr.HeaderActive]          	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.ResizeGrip]            	= ImVec4(0.41, 0.19, 0.63, 0.20)
			colors[clr.ResizeGripHovered]     	= ImVec4(0.41, 0.19, 0.63, 0.78)
			colors[clr.ResizeGripActive]      	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.CloseButton]           	= ImVec4(1.00, 1.00, 1.00, 0.75)
			colors[clr.CloseButtonHovered]    	= ImVec4(0.88, 0.74, 1.00, 0.59)
			colors[clr.CloseButtonActive]     	= ImVec4(0.88, 0.85, 0.92, 1.00)
			colors[clr.PlotLines]             	= ImVec4(0.89, 0.85, 0.92, 0.63)
			colors[clr.PlotLinesHovered]      	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.PlotHistogram]         	= ImVec4(0.89, 0.85, 0.92, 0.63)
			colors[clr.PlotHistogramHovered]  	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.TextSelectedBg]        	= ImVec4(0.41, 0.19, 0.63, 0.43)
			colors[clr.ModalWindowDarkening]  	= ImVec4(0.20, 0.20, 0.20, 0.35)
			--textcolorinhex						= '{ffffff}'
		elseif configuration.main_settings.style == 4 then 
			colors[clr.Text]                   	= ImVec4(0.90, 0.90, 0.90, 1.00)
			colors[clr.TextDisabled]           	= ImVec4(0.60, 0.60, 0.60, 1.00)
			colors[clr.WindowBg]               	= ImVec4(0.08, 0.08, 0.08, 1.00)
			colors[clr.ChildWindowBg]          	= ImVec4(0.10, 0.10, 0.10, 1.00)
			colors[clr.PopupBg]                	= ImVec4(0.08, 0.08, 0.08, 1.00)
			colors[clr.Border]                 	= ImVec4(0.70, 0.70, 0.70, 0.40)
			colors[clr.BorderShadow]           	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg]                	= ImVec4(0.15, 0.15, 0.15, 1.00)
			colors[clr.FrameBgHovered]         	= ImVec4(0.19, 0.19, 0.19, 0.71)
			colors[clr.FrameBgActive]          	= ImVec4(0.34, 0.34, 0.34, 0.79)
			colors[clr.TitleBg]                	= ImVec4(0.00, 0.69, 0.33, 0.80)
			colors[clr.TitleBgActive]          	= ImVec4(0.00, 0.74, 0.36, 1.00)
			colors[clr.TitleBgCollapsed]       	= ImVec4(0.00, 0.69, 0.33, 0.50)
			colors[clr.MenuBarBg]              	= ImVec4(0.00, 0.80, 0.38, 1.00)
			colors[clr.ScrollbarBg]            	= ImVec4(0.16, 0.16, 0.16, 1.00)
			colors[clr.ScrollbarGrab]          	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.00, 0.82, 0.39, 1.00)
			colors[clr.ScrollbarGrabActive]    	= ImVec4(0.00, 1.00, 0.48, 1.00)
			colors[clr.ComboBg]                	= ImVec4(0.20, 0.20, 0.20, 0.99)
			colors[clr.CheckMark]              	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.SliderGrab]             	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.SliderGrabActive]       	= ImVec4(0.00, 0.77, 0.37, 1.00)
			colors[clr.Button]                 	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.ButtonHovered]          	= ImVec4(0.00, 0.82, 0.39, 1.00)
			colors[clr.ButtonActive]           	= ImVec4(0.00, 0.87, 0.42, 1.00)
			colors[clr.Header]                 	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.HeaderHovered]          	= ImVec4(0.00, 0.76, 0.37, 0.57)
			colors[clr.HeaderActive]           	= ImVec4(0.00, 0.88, 0.42, 0.89)
			colors[clr.Separator]              	= ImVec4(1.00, 1.00, 1.00, 0.40)
			colors[clr.SeparatorHovered]       	= ImVec4(1.00, 1.00, 1.00, 0.60)
			colors[clr.SeparatorActive]        	= ImVec4(1.00, 1.00, 1.00, 0.80)
			colors[clr.ResizeGrip]             	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.ResizeGripHovered]      	= ImVec4(0.00, 0.76, 0.37, 1.00)
			colors[clr.ResizeGripActive]       	= ImVec4(0.00, 0.86, 0.41, 1.00)
			colors[clr.CloseButton]            	= ImVec4(0.00, 0.82, 0.39, 1.00)
			colors[clr.CloseButtonHovered]     	= ImVec4(0.00, 0.88, 0.42, 1.00)
			colors[clr.CloseButtonActive]      	= ImVec4(0.00, 1.00, 0.48, 1.00)
			colors[clr.PlotLines]              	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.PlotLinesHovered]       	= ImVec4(0.00, 0.74, 0.36, 1.00)
			colors[clr.PlotHistogram]          	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.PlotHistogramHovered]   	= ImVec4(0.00, 0.80, 0.38, 1.00)
			colors[clr.TextSelectedBg]         	= ImVec4(0.00, 0.69, 0.33, 0.72)
			colors[clr.ModalWindowDarkening]   	= ImVec4(0.17, 0.17, 0.17, 0.48)
			--textcolorinhex						= '{e5e5e5}'
		else
			configuration.main_settings.style = 0
			checkstyle()
		end
	end

	function string.split(inputstr, sep)
		if sep == nil then
				sep = '%s'
		end
		local t={} ; i=1
		for str in string.gmatch(inputstr, '([^'..sep..']+)') do
				t[i] = str
				i = i + 1
		end
		return t
	end

	--Разделение на точки:
	function string.separate(a)
		local b, e = ('%d'):format(a):gsub('^%-', '')
		local c = b:reverse():gsub('%d%d%d', '%1.')
		local d = c:reverse():gsub('^%.', '')
		return (e == 1 and '-' or '')..d
	end

	function string.rlower(s)
		local russian_characters = {
			[155] = '[', [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
		}
		s = s:lower()
		local strlen = s:len()
		if strlen == 0 then return s end
		s = s:lower()
		local output = ''
		for i = 1, strlen do
			local ch = s:byte(i)
			if ch >= 192 and ch <= 223 then output = output .. russian_characters[ch + 32]
			elseif ch == 168 then output = output .. russian_characters[184]
			else output = output .. string.char(ch)
			end
		end
		return output
	end

	function GetMyGender() -- bhelper
		local skins = {
			[0] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61, 62, 66, 67, 68, 70, 71, 72, 73, 78, 79, 80, 81, 82, 83, 84, 86, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146, 147, 149, 153, 154, 155, 156, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 170, 171, 173, 174, 175, 176, 177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 200, 202, 203, 204, 206, 208, 209, 210, 212, 213, 217, 220, 221, 222, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 247, 248, 249, 250, 252, 253, 254, 255, 258, 259, 260, 261, 262, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 299, 300, 301, 302, 303, 304, 305, 310, 311}, 
			[1] = {9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 65, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298, 306, 307, 308, 309}
		}
		for k, v in pairs(skins) do
			for _, skin in pairs(v) do
				if skin == getCharModel(playerPed) then
					usersettings.gender.v = k
					configuration.main_settings.gender = k
					if inicfg.save(configuration,'SWAT Helper') then
						local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
						ASHelperMessage(string.format('Пол был выбран: {%06X}%s', join_rgb(r, g, b),usersettings.gender.v and 'Мужской' or 'Женский'))
					end
					return k
				end
			end
		end
		return nil
	end

	function imgui.GetKeys(bool,maxkeys)
		if bool then
			local function getDownKeys()
				local curkeys = ''
				local bool = false
				for k, v in pairs(vkeys) do
					if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
						if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
							curkeys = v
						end
					end
				end
				for k, v in pairs(vkeys) do
					if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
						if tostring(curkeys):len() == 0 then
							curkeys = v
						else
							curkeys = curkeys .. ' ' .. v
						end
						bool = true
					end
				end
				return curkeys, bool
			end
			
			local tKeys = string.split(getDownKeys(), ' ')
			if #tKeys ~= 0 then
				for i = 1, #tKeys do
					if maxkeys > 1 then
						if #tKeys == 1 then
							str = vkeys.id_to_name(tonumber(tKeys[i]))
							return true,'ЛКМ - сохранение '..str
						elseif #tKeys == maxkeys then
							if str and not str:find(vkeys.id_to_name(tonumber(tKeys[i]))) then
								str = str .. ' + ' .. vkeys.id_to_name(tonumber(tKeys[i]))
								return false,str
							end
						else
							return true,'None'
						end
					else
						str = vkeys.id_to_name(tonumber(tKeys[i]))
						return false, str
					end
				end
			else
				return true,'None'
			end
		end
	end

	function imgui.SmoothButton(bool, name, wide)
		local animTime = 0.25
		local drawList = imgui.GetWindowDrawList()
		local p1 = imgui.GetCursorScreenPos()
		local p2 = imgui.GetCursorPos()
		local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetRGBA()
		local hex = string.format('%06X', bit.band(join_argb(a, b, g, r), 0xFFFFFF))
		local button = imgui.InvisibleButton(name, imgui.ImVec2(wide, 30))
		if button and not bool then navigateLast = os.clock() end
		local pressed = imgui.IsItemActive()
		drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 220, p1.y + 30), ('0x20%s'):format(hex))
		if bool then
			if navigateLast and (os.clock() - navigateLast) < animTime then
				local wide = (os.clock() - navigateLast) * (wide / animTime)
				drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 30), ('0x80%s'):format(hex))
				drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 5, p1.y + 30), ('0xFF%s'):format(hex))
			else
				drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 30), ('0x80%s'):format(hex))
				drawList:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 30 or p1.y + 30)), ('0xFF%s'):format(hex))
			end
		else
			if imgui.IsItemHovered() then
				drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 30), ('0x10%s'):format(hex))
				drawList:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 30 or p1.y + 30)), ('0x70%s'):format(hex))
			end
		end
		imgui.SameLine(10)
		imgui.SetCursorPos(imgui.ImVec2((wide - imgui.CalcTextSize(name).x) / 2, p2.y + 8))
		imgui.Text(name)
		imgui.SetCursorPosY(p2.y + 36.7)
		return button
	end

	function imgui.BoolButton(bool, name) -- из https://www.blast.hk/threads/59761/
		if type(bool) ~= 'boolean' then return end
		if bool then
			local button = imgui.Button(name)
			return button
		else
			local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/1))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/1))
			imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
			local button = imgui.Button(name)
			imgui.PopStyleColor(4)
			return button
		end
	end

	function imgui.LockedButton(text, size)
		local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
		local button = imgui.Button(text, size)
		imgui.PopStyleColor(4)
		return button
	end



	function imgui.TextColoredRGB(text,align)
		local width = imgui.GetWindowWidth()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local ImVec4 = imgui.ImVec4
	
		local explode_argb = function(argb)
			local a = bit.band(bit.rshift(argb, 24), 0xFF)
			local r = bit.band(bit.rshift(argb, 16), 0xFF)
			local g = bit.band(bit.rshift(argb, 8), 0xFF)
			local b = bit.band(argb, 0xFF)
			return a, r, g, b
		end
	
		local getcolor = function(color)
			if color:sub(1, 6):upper() == 'SSSSSS' then
				local r, g, b = colors[1].x, colors[1].y, colors[1].z
				local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
				return ImVec4(r, g, b, a / 255)
			end
			local color = type(color) == 'string' and tonumber(color, 16) or color
			if type(color) ~= 'number' then return end
			local r, g, b, a = explode_argb(color)
			return imgui.ImColor(r, g, b, a):GetVec4()
		end
	
		local render_text = function(text_)
			for w in text_:gmatch('[^\r\n]+') do
				local textsize = w:gsub('{.-}', '')
				local text_width = imgui.CalcTextSize(u8(textsize))
				if align == 1 then imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
				elseif align == 2 then imgui.SetCursorPosX(imgui.GetCursorPosX() + width - text_width.x - imgui.GetScrollX() - 2 * imgui.GetStyle().ItemSpacing.x - imgui.GetStyle().ScrollbarSize)
				end
				local text, colors_, m = {}, {}, 1
				w = w:gsub('{(......)}', '{%1FF}')
				while w:find('{........}') do
					local n, k = w:find('{........}')
					local color = getcolor(w:sub(n + 1, k - 1))
					if color then
						text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
						colors_[#colors_ + 1] = color
						m = n
					end
					w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
				end
				if text[0] then
					for i = 0, #text do
						imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
						imgui.SameLine(nil, 0)
					end
					imgui.NewLine()
				else imgui.Text(u8(w)) end
			end
		end
		render_text(text)
	end

	function imgui.Hint(text, delay, action)
		if imgui.IsItemHovered() then
			if hintanim == nil then hintanim = os.clock() + (delay and delay or 0.0) end
			local alpha = (os.clock() - hintanim) * 5
			if os.clock() >= hintanim then
				imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
				imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
					imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.11, 0.11, 0.11, 0.80))
						imgui.BeginTooltip()
						imgui.PushTextWrapPos(450)
						imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(fa.ICON_FA_INFO_CIRCLE..u8' Подсказка:').x / 2 )
						imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_FA_INFO_CIRCLE..u8' Подсказка')
						imgui.TextColoredRGB(('{FFFFFF}%s'):format(text),1)
						if action ~= nil then imgui.Text(('\n %s'):format(action)) end
						if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then hintanim = nil end
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					imgui.PopStyleColor()
				imgui.PopStyleVar(2)
			end
		end
	end

	function Rule()
		if imgui.BeginPopupModal(u8('Правила'), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
			imgui.TextColoredRGB(ruless[RuleSelect].name,1)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			imgui.PushItemWidth(200)
			imgui.InputText('##search_rule', search_rule, imgui.InputTextFlags.EnterReturnsTrue) 
			if not imgui.IsItemActive() and #search_rule.v == 0 then
				imgui.SameLine((imgui.GetWindowWidth() - imgui.CalcTextSize(fa.ICON_FA_SEARCH..u8(' Искать')).x) / 2)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), fa.ICON_FA_SEARCH..u8(' Искать'))
			end
			imgui.SameLine(928)
			if imgui.BoolButton(rule_align.v == 1,fa.ICON_FA_ALIGN_LEFT, imgui.ImVec2(40, 20)) then
				rule_align.v = 1
				configuration.main_settings.rule_align = rule_align.v
				inicfg.save(configuration,'SWAT Helper.ini')
			end
			imgui.SameLine()
			if imgui.BoolButton(rule_align.v == 2,fa.ICON_FA_ALIGN_CENTER, imgui.ImVec2(40, 20)) then
				rule_align.v = 2
				configuration.main_settings.rule_align = rule_align.v
				inicfg.save(configuration,'SWAT Helper.ini')
			end
			imgui.SameLine()
			if imgui.BoolButton(rule_align.v == 3,fa.ICON_FA_ALIGN_RIGHT, imgui.ImVec2(40, 20)) then
				rule_align.v = 3
				configuration.main_settings.rule_align = rule_align.v
				inicfg.save(configuration,'SWAT Helper.ini')
			end
			imgui.BeginChild('##Правила', imgui.ImVec2(1500, 800), true)
			for _,line in ipairs(ruless[RuleSelect].text) do
				if #search_rule.v < 1 then
					imgui.TextColoredRGB(line,rule_align.v-1)
					imgui.Hint('Двойной клик перенесёт строку в чат.', 2)
					if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
						sampSetChatInputEnabled(true)
						sampSetChatInputText(line:gsub('%{.+%}',''))
					end
				else
					if string.rlower(line):find(string.rlower(u8:decode(search_rule.v)):gsub('(%p)','(%%p)')) then
						imgui.TextColoredRGB(line,rule_align.v-1)
						imgui.Hint('Двойной клик перенесёт строку в чат.', 2)
						if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
							sampSetChatInputEnabled(true)
							sampSetChatInputText(line:gsub('%{.+%}',''))
						end
					end
				end	
			end
			imgui.EndChild()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			if imgui.Button(u8'Закрыть',imgui.ImVec2(200,25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
	end

	function otheractions()
		if imgui.BeginPopup(u8'Остальное', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			if imgui.Button(u8'Сбросить конфиг '..(fa.ICON_FA_TRASH), imgui.ImVec2(160,25)) then
				windows.imgui_settings.v = false
				windows.imgui_fm.v = false
				windows.imgui_sobes.v = false
				windows.imgui_lect.v = false
				windows.imgui_binder.v = false
				windows.imgui_depart.v = false
				windows.imgui_changelog.v = false
				imgui.ShowCursor = false
				os.remove('moonloader/config/SWAT Helper.ini')
				configuration = {}
				NoErrors = true
				thisScript():reload()
				imgui.CloseCurrentPopup()
			end
			imgui.Hint('{CC0000}После нажатия все ваши бинды, настройки\n{CC0000} и остальное будут сброшены.')
			if imgui.Button(u8'Перезагрузить скрипт '..(fa.ICON_FA_REDO_ALT), imgui.ImVec2(160,25)) then
				NoErrors = true
				thisScript():reload()
			end
			if imgui.Button(u8'Выгрузить скрипт '..(fa.ICON_FA_LOCK), imgui.ImVec2(160,25)) then
				NoErrors = true
				thisScript():unload()
			end
			if imgui.Button(u8'Очистить чат '..(fa.ICON_FA_COMMENT_ALT), imgui.ImVec2(160,25)) then
				local memory = require 'memory'
				memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
				memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
				memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
			end
			imgui.EndPopup()
		end
	end

	function communicate()
		if imgui.BeginPopup(u8'Связь', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.23, 0.49, 0.96, 0.8))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.23, 0.49, 0.96, 0.9))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.23, 0.49, 0.96, 1))
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))
			if imgui.Button(u8'ВКонтакте', imgui.ImVec2(90, 25)) then
				ASHelperMessage('Ссылка была скопирована')
				setClipboardText('https://vk.com/onligifen')
			end
			imgui.PopStyleColor(4)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.46, 0.51, 0.85, 0.8))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.46, 0.51, 0.85, 0.9))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.46, 0.51, 0.85, 1))
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))
			if imgui.Button(u8'Discord', imgui.ImVec2(90, 25)) then
				ASHelperMessage('Ссылка была скопирована')
				setClipboardText('&to&#1676')
			end
			imgui.PopStyleColor(3)
			imgui.EndPopup()
		end
	end

	function editquestion()
		if imgui.BeginPopup(u8'Редактор вопросов', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.Text(u8'Название кнопки:')
			imgui.SameLine()
			imgui.SetCursorPosX(125)
			imgui.InputText('##questeditorname', questionsettings.questionname)
			imgui.Text(u8'Вопрос: ')
			imgui.SameLine()
			imgui.SetCursorPosX(125)
			imgui.InputText('##questeditorques', questionsettings.questionques)
			imgui.Text(u8'Подсказка: ')
			imgui.SameLine()
			imgui.SetCursorPosX(125)
			imgui.InputText('##questeditorhint', questionsettings.questionhint)
			imgui.SetCursorPosX( (imgui.GetWindowWidth() - 300 - imgui.GetStyle().ItemSpacing.x) / 2 )
			if #questionsettings.questionhint.v > 0 and #questionsettings.questionques.v > 0 and #questionsettings.questionname.v > 0 then
				if imgui.Button(u8'Сохранить####questeditor', imgui.ImVec2(150, 25)) then
					if question_number == nil then 
						table.insert(questions.questions, {
							bname = u8:decode(tostring(questionsettings.questionname.v)),
							bq = u8:decode(tostring(questionsettings.questionques.v)),
							bhint = u8:decode(tostring(questionsettings.questionhint.v)),
						})
					else
						questions.questions[question_number].bname = u8:decode(tostring(questionsettings.questionname.v))
						questions.questions[question_number].bq = u8:decode(tostring(questionsettings.questionques.v))
						questions.questions[question_number].bhint = u8:decode(tostring(questionsettings.questionhint.v))
					end
					local file = io.open(getWorkingDirectory()..'\\SWAT Helper\\Questions.json', 'w')
					file:write(encodeJson(questions))
					file:close()
					imgui.CloseCurrentPopup()
				end
			else
				imgui.LockedButton(u8'Сохранить####questeditor', imgui.ImVec2(150, 25))
				imgui.Hint('Вы ввели не все параметры. Переповерьте всё.')
			end
			imgui.SameLine()
			if imgui.Button(u8'Отменить##questeditor', imgui.ImVec2(150, 25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
	end

	function editlection()
		if imgui.BeginPopupModal(u8'Редактор лекций', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.Text(u8'Название лекции:')
			imgui.SameLine()
			imgui.SetCursorPosY(35)
			imgui.InputText('##lecteditor', lectionsettings.lection_name)
			imgui.Text(u8'Текст лекции: ')
			imgui.InputTextMultiline('##lecteditortext', lectionsettings.lection_text, imgui.ImVec2(700, 300))
			imgui.SetCursorPosX( (imgui.GetWindowWidth() - 300 - imgui.GetStyle().ItemSpacing.x) / 2 )
			if #lectionsettings.lection_name.v > 0 and #lectionsettings.lection_text.v > 0 then
				if imgui.Button(u8'Сохранить##lecteditor', imgui.ImVec2(150, 25)) then
					local pack = function(text, match)
						local array = {}
						for line in text:gmatch('[^'..match..']+') do
							array[#array + 1] = line
						end
						return array
					end
					if lection_number == nil then 
						table.insert(lections.data, {
							name = u8:decode(tostring(lectionsettings.lection_name.v)),
							text = pack(u8:decode(tostring(lectionsettings.lection_text.v)), '\n')
						})
					else
						lections.data[lection_number].name = u8:decode(tostring(lectionsettings.lection_name.v))
						lections.data[lection_number].text = pack(u8:decode(tostring(lectionsettings.lection_text.v)), '\n')
					end
					local file = io.open(getWorkingDirectory()..'\\SWAT Helper\\Lections.json', 'w')
					file:write(encodeJson(lections))
					file:close()
					imgui.CloseCurrentPopup()
				end
			else
				imgui.LockedButton(u8'Сохранить##lecteditor', imgui.ImVec2(150, 25))
				imgui.Hint('Вы ввели не все параметры. Переповерьте всё.')
			end
			imgui.SameLine()
			if imgui.Button(u8'Отменить##lecteditor', imgui.ImVec2(150, 25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
	end

	function bindertags()
		if imgui.BeginPopup(u8'Тэги', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
			for k,v in pairs(tagbuttons) do
				if imgui.Button(u8(tagbuttons[k].name),imgui.ImVec2(150,25)) then
					bindersettings.binderbuff.v = bindersettings.binderbuff.v..''..u8(tagbuttons[k].name)
					ASHelperMessage('Тэг был скопирован.')
				end
				imgui.SameLine()
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8(tagbuttons[k].hint))
					imgui.EndTooltip()
				end
				imgui.Text(u8(tagbuttons[k].text))
			end
			imgui.EndPopup()
		end
	end

	function imgui.OnDrawFrame()
		if windows.imgui_fm.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Меню быстрого доступа', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus  + (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
			if windowtype == 0 then
imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_SMILE..u8' Пригласить в семью', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local faminvite = fastmenuID
										inprocess = true
										sampSendChat(('/faminvite %s'):format(faminvite))
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local faminvite = fastmenuID
										inprocess = true
										sampSendChat(('/faminvite %s'):format(faminvite))
										inprocess = false
									end)
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end			
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_TRASH..u8' Надеть наручники', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local cuff = fastmenuID
										inprocess = true
										sampSendChat('/me сняв с тактического пояса наручники, {gender:нацепил|нацепила} их на руки подозреваемого, {gender:застегнул|застегнула} наручники')
			                            wait(1000)
										sampSendChat(('/cuff %s'):format(cuff))
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local cuff = fastmenuID
										inprocess = true
										sampSendChat('/me сняв с тактического пояса наручники, {gender:нацепил|нацепила} их на руки подозреваемого, {gender:застегнул|застегнула} наручники')
			                            wait(1000)
										sampSendChat(('/cuff %s'):format(cuff))
										inprocess = false
									end)
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_SMILE..u8' Снять наручники', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local uncuff = fastmenuID
										inprocess = true
										sampSendChat('/me достав ключик с тактического пояса, {gender:вставил|вставила} его в замочек и {gender:снял|сняла} наручники с преступника')
			                            wait(1000)
										sampSendChat(('/uncuff %s'):format(uncuff))
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local uncuff = fastmenuID
										inprocess = true
										sampSendChat('/me достав ключик с тактического пояса, {gender:вставил|вставила} его в замочек и {gender:снял|сняла} наручники с преступника')
			                            wait(1000)
										sampSendChat(('/uncuff %s'):format(uncuff))
										inprocess = false
									end)
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_STAMP..u8' Сорвать маску', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local unmask = fastmenuID
										inprocess = true
										sampSendChat('/me резким движением правой руки {gender:сорвал|сорвала} маску с лица преступника, {gender:откинул|откинула} её в сторону')
			                            wait(1000)
										sampSendChat(('/unmask %s'):format(unmask))
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local unmask = fastmenuID
										inprocess = true
										sampSendChat('/me резким движением правой руки {gender:сорвал|сорвала} маску с лица преступника, {gender:откинул|откинула} её в сторону')
			                            wait(1000)
										sampSendChat(('/unmask %s'):format(unmask))
										inprocess = false
									end)
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_PLUS_CIRCLE..u8' Обыскать', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local frisk = fastmenuID
										inprocess = true
										sampSendChat('/me надев перчатки, осторожно {gender:обыскал|обыскала} всё тело подозреваемого')
			                            wait(1000)
										sampSendChat(('/frisk %s'):format(frisk))
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local frisk = fastmenuID
										inprocess = true
										sampSendChat('/me надев перчатки, осторожно {gender:обыскал|обыскала} всё тело подозреваемого')
			                            wait(1000)
										sampSendChat(('/frisk %s'):format(frisk))
										inprocess = false
									end)
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_USER_PLUS..u8' Затащить в машину', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local incar = fastmenuID
										inprocess = true
										sampSendChat('/todo Голову аккуратнее*сажая преступника в машину, открывая дверь крузера, пригибая голову преступника')
			                            wait(1000)
										sampSendChat(('/incar %s 2'):format(incar))
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local incar = fastmenuID
										inprocess = true
										sampSendChat('/todo Голову аккуратнее*сажая преступника в машину, открывая дверь крузера, пригибая голову преступника')
			                            wait(1000)
										sampSendChat(('/incar %s 3'):format(incar))
										inprocess = false
									end)
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.Hint('ЛКМ - посадить на второе место, ПКМ - посадить на третье место',0)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_TIMES..u8' Вести за собой', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local gotome = fastmenuID
										inprocess = true
										sampSendChat('/me опустив голову преступника вниз, {gender:схватил|схватила} за цепь наручников и {gender:повел|повела} его впереди себя')
			                            wait(1000)
										sampSendChat(('/gotome %s'):format(gotome))
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local gotome = fastmenuID
										inprocess = true
										sampSendChat('/me опустив голову преступника вниз, {gender:схватил|схватила} за цепь наручников и {gender:повел|повела} его впереди себя')
			                            wait(1000)
										sampSendChat(('/gotome %s'):format(gotome))
										inprocess = false
									end)
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_ARROW_RIGHT..u8' Правила миранды', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										
										inprocess = true
										sampSendChat('Вы имеете право хранить молчание.')
			                            wait(2500)
										sampSendChat('Всё, что вы скажете, может и будет использовано против вас в суде.')
										wait(2500)
										sampSendChat('Ваш адвокат может присутствовать при допросе.')
										wait(3500)
										sampSendChat('Если вы не можете оплатить услуги адвоката, он будет предоставлен вам государством.')
										wait(2500)
										sampSendChat('Вы понимаете свои права?')
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										
										inprocess = true
										sampSendChat('Вы имеете право хранить молчание.')
			                            wait(2500)
										sampSendChat('Всё, что вы скажете, может и будет использовано против вас в суде.')
										wait(2500)
										sampSendChat('Ваш адвокат может присутствовать при допросе.')
										wait(3500)
										sampSendChat('Если вы не можете оплатить услуги адвоката, он будет предоставлен вам государством.')
										wait(2500)
										sampSendChat('Вы понимаете свои права?')
										inprocess = false
									end)
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_USER_PLUS..u8' Выдать розыск', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local su = fastmenuID
										inprocess = true
										sampSetChatInputText(('/asu %s'):format(su))
										ASHelperMessage('Команда выведена в чат')
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local su = fastmenuID
										inprocess = true
										sampSetChatInputText(('/asu %s'):format(su))
										ASHelperMessage('Команда выведена в чат')
										inprocess = false
									end)
								end
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_USER_PLUS..u8' Принять в организацию', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 0 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local inviteid = fastmenuID
										inprocess = true
										sampSendChat('/todo Поздравляю, Вы наш новый сотрудник*передавая человеку форму и жетон')
			                            wait(1000)
										sampSendChat(('/invite %s'):format(inviteid))
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local inviteid = fastmenuID
										inprocess = true
										sampSendChat('/todo Поздравляю, Вы наш новый сотрудник*передавая человеку форму и жетон')
			                            wait(1000)
										sampSendChat(('/invite %s'):format(inviteid))
										inprocess = false
									end)
								end
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.Hint('ЛКМ/ПКМ для принятия человека в организацию',0)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Уволить из организации', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							imgui.SetScrollY(0)
							windowtype = 3
							uninvitebuf.v = ''
							blacklistbuf.v = ''
							uninvitebox.v = false
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' Изменить должность', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							imgui.SetScrollY(0)
							Ranks_select.v = 0
							windowtype = 4
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_SLASH..u8' Занести в чёрный список', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							imgui.SetScrollY(0)
							windowtype = 5
							blacklistbuff.v = ''
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER..u8' Убрать из чёрного списка', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local unblacklistid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                            wait(1000)
								sampSendChat(('/unblacklist %s'):format(unblacklistid))
								inprocess = false
							end)
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FROWN..u8' Выдать выговор сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							imgui.SetScrollY(0)
							fwarnbuff.v = ''
							windowtype = 6
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_SMILE..u8' Снять выговор сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local unfwarnid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                            wait(1000)
								sampSendChat(('/unfwarn %s'):format(unfwarnid))
								inprocess = false
							end)
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' Выдать мут сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							imgui.SetScrollY(0)
							fmutebuff.v = ''
							fmuteint.v = 0
							windowtype = 7
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' Снять мут сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local funmuteid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                            wait(1000)
								sampSendChat(('/funmute %s'):format(funmuteid))
								inprocess = false
							end)
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_CLOCK..u8' Назначить куратора', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local curatur = fastmenuID
								inprocess = true
								sampSendChat(('Куратором тренировки будет - %s. Он раздаст вам задания и введёт в курс дела.'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
								inprocess = false
							end)
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Правила использования департамента '..fa.ICON_FA_STAMP, imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							imgui.SetScrollY(0)
							lastq = false
							windowtype = 8
						else
							ASHelperMessage('Данное действие доступно с 5-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Собеседование/Переводы '..fa.ICON_FA_ELLIPSIS_V, imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							imgui.SetScrollY(0)
							passvalue = true
							mcvalue = true
							passverdict = ''
							mcverdict = ''
							sobesetap = 0
							sobesdecline_select.v = 0
							windows.imgui_fm.v = false
							windows.imgui_sobes.v = true
						else
							ASHelperMessage('Данное действие доступно с 5-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
			end
	
			if windowtype == 1 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 3 then
				imgui.TextColoredRGB('Причина увольнения:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'').x) / 5.7)
				imgui.InputText(u8'    ', uninvitebuf)
				if uninvitebox.v then
					imgui.TextColoredRGB('Причина ЧС:',1)
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8' ').x) / 5.7)
					imgui.InputText(u8' ', blacklistbuf)
				end
				imgui.Checkbox(u8'Уволить с ЧС', uninvitebox)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Уволить '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 0 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							if uninvitebuf.v == nil or uninvitebuf.v == '' then
								ASHelperMessage('Введите причину увольнения!')
							else
								if uninvitebox.v then
									if blacklistbuf.v == nil or blacklistbuf.v == '' then
										ASHelperMessage('Введите причину занесения в ЧС!')
									else
										windows.imgui_fm.v = false
										lua_thread.create(function()
											local uninviteid = fastmenuID
											inprocess = true
											sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                            wait(1000)
											sampSendChat(('/uninvite %s %s'):format(uninviteid,u8:decode(uninvitebuf.v)))
											wait(2000)
											sampSendChat(('/blacklist %s %s'):format(uninviteid,u8:decode(blacklistbuf.v)))
											inprocess = false
										end)
									end
								else
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local uninviteid = fastmenuID
										inprocess = true
										sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                            wait(1000)
										sampSendChat(('/uninvite %s %s'):format(uninviteid,u8:decode(uninvitebuf.v)))
										inprocess = false
									end)
								end
							end
						end
				
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 4 then
				imgui.PushItemWidth(270)
				imgui.Combo(' ', Ranks_select, Ranks_arr, #Ranks_arr)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.42, 0.0, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.52, 0.0, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.62, 0.7, 1.00))
				if imgui.Button(u8'Повысить сотрудника '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(270,40)) then
					if configuration.main_settings.myrankint >= 0 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local changerankid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                            wait(1000)
								sampSendChat(('/giverank %s %s'):format(changerankid,Ranks_select.v+1))
								inprocess = false
							end)
						end
					else
						ASHelperMessage('Данная команда доступна с 9-го ранга.')
					end
				end
				imgui.PopStyleColor(3)
				if imgui.Button(u8'Понизить сотрудника '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(270,30)) then
					if configuration.main_settings.myrankint >= 0 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local changerankid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                            wait(1000)
								sampSendChat(('/giverank %s %s'):format(changerankid,Ranks_select.v+1))
								inprocess = false
							end)
						end
					else
						ASHelperMessage('Данная команда доступна с 9-го ранга.')
					end
				end
				imgui.TextColoredRGB('{808080}названия рангов могут отличаться от ваших',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 5 then
				imgui.TextColoredRGB('Причина занесения в ЧС:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'').x) / 5.7)
				imgui.InputText(u8'                   ', blacklistbuff)
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Занести в ЧС '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 0 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							if blacklistbuff.v == nil or blacklistbuff.v == '' then
								ASHelperMessage('Введите причину занесения в ЧС!')
							else
								windows.imgui_fm.v = false
								lua_thread.create(function()
									local blacklistid = fastmenuID
									inprocess = true
									sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                            wait(1000)
									sampSendChat(('/blacklist %s %s'):format(blacklistid,u8:decode(blacklistbuff.v)))
									inprocess = false
								end)
							end
						end
					else
						ASHelperMessage('Данная команда доступна с 9-го ранга.')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 6 then
				imgui.TextColoredRGB('Причина выговора:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'   ').x) / 5.7)
				imgui.InputText(u8'   ', fwarnbuff)
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Выдать выговор '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
					if fwarnbuff.v == nil or fwarnbuff.v == '' then
						ASHelperMessage('Введите причину выдачи выговора!')
					else
						windows.imgui_fm.v = false
						lua_thread.create(function()
							local fwarnid = fastmenuID
							inprocess = true
							sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                wait(1000)
							sampSendChat(('/fwarn %s %s'):format(fwarnid,u8:decode(fwarnbuff.v)))
							inprocess = false
						end)
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 7 then
				imgui.TextColoredRGB('Причина мута:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'').x) / 5.7)
				imgui.InputText(u8'         ', fmutebuff)
				imgui.TextColoredRGB('Время мута:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8' ').x) / 5.7)
				imgui.InputInt(u8' ', fmuteint)
				imgui.NewLine()
				if imgui.Button(u8'Выдать мут '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if configuration.main_settings.myrankint >= 0 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							if fmutebuff.v == nil or fmutebuff.v == '' then
								ASHelperMessage('Введите причину выдачи мута!')
							else
								if fmuteint.v == nil or fmuteint.v == '' or fmuteint.v == 0 or tostring(fmuteint.v):find('-') then
									ASHelperMessage('Введите корректное время мута!')
								else
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local fmuteid = fastmenuID
										inprocess = true
										sampSendChat('/me {gender:достал|достала} из-за паузухи КПК, {gender:зашёл|зашла} в базу данных, {gender:нашёл|нашла} сотрудника и {gender:изменил|изменила} о нём информацию')
			                            wait(1000)
										sampSendChat(('/fmute %s %s %s'):format(fmuteid,u8:decode(fmuteint.v),u8:decode(fmutebuff.v)))
										inprocess = false
									end)
								end
							end
						end
					else
						ASHelperMessage('Данная команда доступна с 9-го ранга.')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	print(questions.active.redact)
			if windowtype == 8 then
				if #questions.questions ~= 0 then
					if questions.active.redact then
						for k,v in pairs(questions.questions) do
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
							if imgui.Button(u8(v.bname.."##"..k), imgui.ImVec2(200,30)) then
								if not inprocess then
									if string.rlower(v.bhint):find("подсказка") then
										ASHelperMessage(v.bhint)
									else
										ASHelperMessage("Подсказка: "..v.bhint)
									end
									sampSendChat(v.bq)
									lastq = os.clock() - 1
								else
									ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
								end
							end
							imgui.SameLine()
							if imgui.Button(fa.ICON_FA_PEN.."##"..k, imgui.ImVec2(30,30)) then
								question_number = k
								questionsettings.questionname.v = u8(v.bname)
								questionsettings.questionhint.v = u8(v.bhint)
								questionsettings.questionques.v = u8(v.bq)
								imgui.OpenPopup(u8('Редактор вопросов'))
							end
							imgui.SameLine()
							if imgui.Button(fa.ICON_FA_TRASH.."##"..k, imgui.ImVec2(30,30)) then
								table.remove(questions.questions,k)
								local file = io.open(getWorkingDirectory()..'\\SWAT Helper\\Questions.json', 'w')
								file:write(encodeJson(questions))
								file:close()
							end
						end
					else
						for k,v in pairs(questions.questions) do
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
							if imgui.Button(u8(v.bname), imgui.ImVec2(285,30)) then
								if not inprocess then
									if string.rlower(v.bhint):find("подсказка") then
										ASHelperMessage(v.bhint)
									else
										ASHelperMessage("Подсказка: "..v.bhint)
									end
									sampSendChat(v.bq)
									lastq = os.clock() - 1
								else
									ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
								end
							end
						end
					end
				else
					imgui.TextColoredRGB("Восстановить все вопросы",1)
					if imgui.IsItemHovered() and imgui.IsMouseReleased(0) then
						questions = default_questions
					end
				end
				imgui.NewLine()
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 285) / 1)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				imgui.Button(u8'Одобрить', imgui.ImVec2(137,35))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if imgui.IsMouseReleased(0) then
								windows.imgui_fm.v = false
								sampSendChat(('Вы сдали правила использования рации департамента!'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
							end
							if imgui.IsMouseReleased(1) then
								if configuration.main_settings.myrankint >= 0 then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local changerankid = fastmenuID
										inprocess = true
										sampSendChat(('/r %s успешно сдал правила рации департамента!'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
										inprocess = false
									end)
								
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.Hint('ЛКМ для информирования о сдаче\n{FFFFFF}ПКМ для уведомления в рацию',0)
				imgui.PopStyleColor(2)
				imgui.SameLine()
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отказать', imgui.ImVec2(137,35)) then
					if not inprocess then
						sampSendChat(('Очень жаль, но вы не смогли сдать правила рации департамента. Подучите и приходите в следующий раз.'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
						windows.imgui_fm.v = false
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 605) / 1.8)
				imgui.Text(fa.ICON_FA_CLOCK.." "..(lastq == false and u8"0 с. назад" or math.floor(os.clock()-lastq)..u8" с. назад"))
				imgui.Hint("Прошедшее время с последнего вопроса.")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 1.8)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 660) / 1.8)
				if not questions.active.redact then
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.80, 0.25, 0.25, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.70, 0.25, 0.25, 1.00))
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.90, 0.25, 0.25, 1.00))
				else
					print(#questions.questions)
					if #questions.questions <= 7 then
						imgui.SetCursorPosX(imgui.GetWindowWidth() - 95)
						if imgui.Button(fa.ICON_FA_PLUS_CIRCLE,imgui.ImVec2(50,25)) then
							question_number = nil
							questionsettings.questionname.v = u8('')
							questionsettings.questionhint.v = u8('')
							questionsettings.questionques.v = u8('')
							imgui.OpenPopup(u8('Редактор вопросов'))
						end
						imgui.SameLine()
					end
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.70, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.60, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.50, 0.00, 1.00))
				end
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				if imgui.Button(fa.ICON_FA_COG, imgui.ImVec2(25,25)) then
					questions.active.redact = not questions.active.redact
				end
				imgui.PopStyleColor(3)
				editquestion()
			end
			if not sampIsPlayerConnected(fastmenuID) then
	        	windows.imgui_fm.v = false
				windows.imgui_sobes.v = false
	        	ASHelperMessage('Игрок с которым вы взаимодействовали вышел из игры!')
	        end
			imgui.End()
		end

		if windows.imgui_sobes.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Меню быстрого доступа', _, imgui.WindowFlags.NoResize + (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus) + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)
			if sobesetap == 0 then
				imgui.TextColoredRGB('Этап 1',1)
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Собеседование: Приветствие', imgui.ImVec2(285,30)) then
					if not inprocess then
						lua_thread.create(function()
							inprocess = true
							sampSendChat(('Здравствуйте, я являюсь сотрудником S.W.A.T и занимаю должность - %s '):format(configuration.main_settings.myrank))
							wait(2000)
							sampSendChat('Вы явились к нам на стажировку?')
							inprocess = false
						end)
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Перевод: Приветствие', imgui.ImVec2(285,30)) then
					if not inprocess then
						lua_thread.create(function()
							inprocess = true
							sampSendChat(('Здравствуйте, я являюсь сотрудником S.W.A.T и занимаю должность - %s '):format(configuration.main_settings.myrank))
							wait(2000)
							sampSendChat('На данынй момент наше подразделение активно ищет в свою академию новых стажёров.')
							wait(3500)
							sampSendChat('Нет ли у вас желания попробовать себя в роли сотрудника SWAT?')
							inprocess = false
						end)
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Попросить документы '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
					if not inprocess then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('Хорошо, для этого покажите мне ваши документы, а именно: паспорт и лицензии')
							sampSendChat('/b /showpass, /showlic, по РП. Пример: /me показал документы.')
							wait(50)
							sobesetap = 1
							inprocess = false
						end)
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
			end

			if sobesetap == 1 then
				imgui.TextColoredRGB("Собеседование: Этап 2",1)
				imgui.Separator()
				if imgui.Button(u8'Сё гуд '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
					if not inprocess then
						lua_thread.create(function()
							inprocess = true
							sampSendChat("/me взяв документы из рук человека напротив {gender:начал|начала} их проверять")
								wait(2000)
								sampSendChat("/todo Хорошо...* отдавая документы обратно")
								wait(2000)
								sampSendChat("Сейчас я задам вам несколько вопросов, вы готовы на них отвечать?")
							wait(50)
							sobesetap = 2
							inprocess = false
						end)
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
			end

			if sobesetap == 2 then
				imgui.TextColoredRGB('Этап 3',1)
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Опыт работы', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							inprocess = true
							sampSendChat('Работали раньше в Министерстве Юстиции? Если да, то какой стаж работы был?')
							inprocess = false
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'3 качества', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							inprocess = true
							sampSendChat('По вашему мнению, какими должен обладать качествами любой сотрудник Министерства Юстиции?')
							inprocess = false
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				
			end

			if sobesetap == 3 then
				imgui.TextColoredRGB('Решение',1)
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				if imgui.Button(u8'Принят', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 0 then
							lua_thread.create(function()
								local inviteid = fastmenuID
								inprocess = true
								sampSendChat('Поздравляю, вы приняты и теперь официально проходите стажировку в подразделение S.W.A.T!')
								wait(2500)
								sampSendChat("/todo Поздравляю, Вы наш новый сотрудник*передавая человеку форму и жетон")
								wait(2500)
								sampSendChat(('/invite %s'):format(inviteid))
								inprocess = false
							end)
						else
							lua_thread.create(function()
								inprocess = true
								sampSendChat('Поздравляю, вы приняты и теперь официально проходите стажировку в подразделение S.W.A.T!')
								wait(2500)
								sampSendChat(('/r %s готов к стажировке и ждёт старших в холле!'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
								wait(3000)
								sampSendChat(('/rb %s id'):format(fastmenuID))
								inprocess = false
							end)
						end
						sobesetap = 0
						windows.imgui_sobes.v = false
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
					if not inprocess then
						lastsobesetap = sobesetap
						sobesetap = 7
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.PopStyleColor(2)
			end

			if sobesetap == 7 then
				imgui.TextColoredRGB('Собеседование: Отклонение',1)
				imgui.Separator()
				imgui.PushItemWidth(270)
				imgui.Combo(' ',sobesdecline_select,sobesdecline_arr , #sobesdecline_arr)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отклонить', imgui.ImVec2(270,30)) then
					if not inprocess then
						sobesetap = 0
						if sobesdecline_select.v == 0 then
							sampSendChat('К сожалению, я не могу принять вас из-за того, что вы находитесь в ЧС.')
							sampSendChat('/b Варн у тебя. С ним нельзя системно принять во фракцию')
						elseif sobesdecline_select.v == 1 then
							sampSendChat('К сожалению, я не могу принять вас из-за того, что вы находитесь в ЧС.')
						elseif sobesdecline_select.v == 2 then
							sampSendChat('К сожалению, я не могу принять вас из-за проблем с вашим паспортом.')
							sampSendChat('/b нонРП ник у тебя. Сменишь - приму.')
						elseif sobesdecline_select.v == 3 then
							sampSendChat('К сожалению, я не могу принять вас из-за того, что у вас отсутствует военный билет.')
							sampSendChat('/b Получить его через /donate, либо в армии 15 часов пробыть')
						elseif sobesdecline_select.v == 4 then
							sampSendChat('К сожалению, я не могу принять вас из-за того, что вы не проживаете в штате 3 года.')
							sampSendChat('/b у тебя нет 3 уровня. Система не даст принять.')
							elseif sobesdecline_select.v == 5 then
							sampSendChat('К сожалению, я не могу принять вас из-за того, что вы недостаточно законопослушный.')
							sampSendChat('/b у тебя нет 35 законки. Система не даст принять.')
							elseif sobesdecline_select.v == 6 then
							sampSendChat('К сожалению, я не могу принять вас из-за того, что вы проф.непригодны.')
						end
						windows.imgui_sobes.v = false
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.PopStyleColor(2)
			end

			if sobesetap ~= 3 and sobesetap ~= 7  then
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
					if not inprocess then
						if mcvalue or passvalue then
							if mcverdict == ("наркозависимость") or mcverdict == ("не полностью здоровый") or passverdict == ("меньше 3 лет в штате") or passverdict == ("не законопослушный") or passverdict == ("игрок в организации") or passverdict == ("был в деморгане") or passverdict == ("в чс") or passverdict == ("есть варны") then
								windows.imgui_sobes.v = false
								if mcverdict == ("наркозависимость") then
									sampSendChat("К сожалению я не могу продолжить собеседование. Вы слишком наркозависимый.")
								elseif mcverdict == ("не полностью здоровый") then
									sampSendChat("К сожалению я не могу продолжить собеседование. Вы не полностью здоровый.")
								elseif passverdict == ("меньше 3 лет в штате") then
									sampSendChat("К сожалению я не могу продолжить собеседование. Вы не проживаете в штате 3 года.")
								elseif passverdict == ("не законопослушный") then
									sampSendChat("К сожалению я не могу продолжить собеседование. Вы недостаточно законопослушный.")
								elseif passverdict == ("игрок в организации") then
									sampSendChat("К сожалению я не могу продолжить собеседование. Вы уже работаете в другой организации.")
								elseif passverdict == ("был в деморгане") then
									sampSendChat("К сожалению я не могу продолжить собеседование. Вы лечились в псих. больнице.")
									sampSendChat("/n поменяй мед. карту")
								elseif passverdict == ("в чс") then
									sampSendChat("К сожалению я не могу продолжить собеседование. Вы находитесь в ЧС.")
								elseif passverdict == ("есть варны") then
									sampSendChat("К сожалению я не могу продолжить собеседование. Вы проф. непригодны.")
									sampSendChat("/n есть варны")
								end							
							else
								lastsobesetap = sobesetap
								sobesetap = 7
							end
						else
							lastsobesetap = sobesetap
							sobesetap = 7
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.PopStyleColor(2)
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'Назад', imgui.ImVec2(137,30)) then
				if sobesetap == 7 then sobesetap = lastsobesetap
				elseif sobesetap ~= 0 then sobesetap = sobesetap - 1
				else
					windows.imgui_sobes.v = false
					windows.imgui_fm.v = true
					windowtype = 0
				end
			end
			imgui.SameLine()
			if sobesetap ~= 3 and sobesetap ~= 7 then
				if imgui.Button(u8'Пропустить этап', imgui.ImVec2(137,30)) then
					if not inprocess then
						sobesetap = sobesetap + 1
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
			end
			if not sampIsPlayerConnected(fastmenuID) then
	        	windows.imgui_fm.v = false
				windows.imgui_sobes.v = false
	        	ASHelperMessage('Игрок с которым вы взаимодействовали вышел из игры!')
	        end
			imgui.End()
		end

		if windows.imgui_settings.v then
			imgui.SetNextWindowSize(imgui.ImVec2(900, 500), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'#settings', windows.imgui_settings, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.Image(configuration.main_settings.style ~= 2 and whiteashelper or blackashelper,imgui.ImVec2(198,25))
			imgui.SameLine(860)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_settings.v = false
			end
			imgui.PopStyleColor(3)
			imgui.SetCursorPos(imgui.ImVec2(187, 22))
			imgui.TextColoredRGB('{808080}'..thisScript().version)
			imgui.Hint('Обновление от 01.08.2021')
			imgui.BeginChild('##Buttons',imgui.ImVec2(230,440),true,imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoScrollWithMouse)
			for number, button in pairs(buttons) do
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 320) / 2)
				if imgui.SmoothButton(settingswindow == number, button, 190) then
					settingswindow = number
				end
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('##Settings',imgui.ImVec2(625,440),true,imgui.WindowFlags.AlwaysAutoResize)
			if settingswindow == 0 then

				imgui.PushFont(fontsize25)
				imgui.TextColoredRGB('Что умеет скрипт?',1)
				imgui.PopFont()
				imgui.TextWrapped(u8([[
	• Меню быстрого доступа: Прицелившись на игрока с помощью ПКМ и нажав кнопку E (по умолчанию), откроется меню быстрого доступа. В данном меню есть все нужные функции, а именно: /cuff, /uncuff, /pull, /gotome и т.д., приглашение в организацию, увольнение из организации, изменение должности, занесение в ЧС, удаление из ЧС, выдача выговоров, удаление выговоров, выдача организационного мута, удаление организационного мута, автоматизированное проведение собеседования со всеми нужными отыгровками.
	
	• Команды: /swat, BB(чит-кодом) - настройки хелпера, /swatbind - биндер хелпера, /swatrek - меню лекций.
	
	• Настройки: Введя команду /swat или чит-код BB, откроются настройки, в которых можно изменять никнейм в приветствии, акцент, создание маркера при выделении, пол, горячую клавишу быстрого меню и другое.
	
	• Биндер: Введя команду /swatbind, откроется полностью работоспособный биндер, в котором вы можете создать абсолютно любой бинд.

	• Меню оповещений: Введя команду /swatrek, откроется меню лекций, в котором вы сможете озвучить/добавить/удалить лекции.]]
	))
			end

			if settingswindow == 1 then

				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Использовать мой ник из таба',usersettings.useservername) then
					if configuration.main_settings.myname == '' then
						usersettings.myname.v = string.gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ')
						configuration.main_settings.myname = usersettings.myname.v
					end
					configuration.main_settings.useservername = usersettings.useservername.v
					inicfg.save(configuration,'SWAT Helper')
				end
				if not usersettings.useservername.v then
					imgui.SetCursorPosX(10)
					if imgui.InputText(u8' ', usersettings.myname) then
						configuration.main_settings.myname = usersettings.myname.v
						inicfg.save(configuration,'SWAT Helper')
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Использовать акцент',usersettings.useaccent) then
					configuration.main_settings.useaccent = usersettings.useaccent.v
					inicfg.save(configuration,'SWAT Helper')
				end
				if usersettings.useaccent.v then
					imgui.PushItemWidth(150)
					imgui.SetCursorPosX(20)
					if imgui.InputText(u8'   ', usersettings.myaccent) then
						configuration.main_settings.myaccent = usersettings.myaccent.v
						inicfg.save(configuration,'SWAT Helper')
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.SetCursorPosX(10)
					imgui.Text('[')
					imgui.SameLine()
					imgui.SetCursorPosX(175)
					imgui.Text(']')
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Создавать маркер при выделении',usersettings.createmarker) then
					if marker ~= nil then
						removeBlip(marker)
					end
					marker = nil
					oldtargettingped = 0
					configuration.main_settings.createmarker = usersettings.createmarker.v
					inicfg.save(configuration,'SWAT Helper')
				end
				imgui.SetCursorPosX(10)
				if imgui.Button(u8'Обновить', imgui.ImVec2(85,25)) then
					getmyrank = true
					sampSendChat('/stats')
				end
				imgui.SameLine()
				imgui.Text(u8'Ваш ранг: '..u8(configuration.main_settings.myrank)..' ('..u8(configuration.main_settings.myrankint)..')')
				imgui.PushItemWidth(85)
				imgui.SetCursorPosX(10)
				if imgui.Combo(u8'',usersettings.gender, {u8'Мужской',u8'Женский'}, 2) then
					configuration.main_settings.gender = usersettings.gender.v
					inicfg.save(configuration,'SWAT Helper')
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.TextColoredRGB('Пол выбран {808080}(?)')
				if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
					GetMyGender()
				end
				imgui.Hint('ЛКМ для автоматического определения.')
			end

			if settingswindow == 2 then
				imgui.Text(fa.ICON_FA_LAYER_GROUP .. u8" Блокнот для записи косяков " .. fa.ICON_FA_LAYER_GROUP)
				imgui.Hint('При перезагрузке скрипта записи исчезают!')
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 600) / 2)
				imgui.PushItemWidth(62)
    imgui.InputTextMultiline("",buff,imgui.ImVec2(450,200))
	if imgui.Button(u8'Начало тренировки',btn_size) then
            lua_thread.create(function()
            sampSendChat('Итак, бойцы, всем доброго времени суток, сейчас для вас пройдёт тренировка!')
			wait(3500)
			sampSendChat('Вся суть тренировки будет рассказана чуть позже, для начала вводная информация.')
			wait(3500)
			sampSendChat('Мною назначается Куратор задания, ослушиваться которого строго запрещено.')
			wait(3500)
			sampSendChat('Если вы вдруг ослушались, вы будете уволены. Ведь ослушаться на реальном задании')
			wait(3500)
			sampSendChat('...значит иметь возможность подвергнуть свою жизнь и жизнь других опасности.')
			wait(3500)
			sampSendChat('На такие риски мы не готовы идти.')
			wait(3500)
			sampSendChat('Если Вы стоите на тренировке, как пень, ваш отчёт будет отказан.')
			wait(4700)
			sampSendChat('Чтобы отчёт был одобрен, вам нужно выполнить все задачи, которые перед вами будут поставлены Куратором.')
              end)
           end
		   

		imgui.Text(u8'Подсказка')
		imgui.Hint('Куратора можно назначить через быстрое меню(ПКМ+Е)')
				imgui.PopItemWidth()
			end

			if settingswindow == 3 then
				if imgui.Button(u8'Изменить кнопку быстрого меню', imgui.ImVec2(-1,35.9)) then
					getbindkey = not getbindkey
				end
				if getbindkey then
					imgui.Hint('Нажмите любую клавишу')
					getbindkey,configuration.main_settings.usefastmenu = imgui.GetKeys(getbindkey,1)
				else
					imgui.Hint('ПКМ + '..configuration.main_settings.usefastmenu)
				end
				if imgui.Button(u8(windows.imgui_binder.v and 'Закрыть' or 'Открыть')..u8' биндер', imgui.ImVec2(-1,35.9)) then
					choosedslot = nil
					windows.imgui_binder.v = not windows.imgui_binder.v
				end
				if imgui.Button(u8(windows.imgui_lect.v and 'Закрыть' or 'Открыть')..u8' меню лекций', imgui.ImVec2(-1,35.9)) then
					if configuration.main_settings.myrankint >= 0 then
						windows.imgui_lect.v = not windows.imgui_lect.v
					else
						ASHelperMessage('Данная функция доступна с 5-го ранга.')
					end
				end
				if imgui.Button(u8(windows.imgui_depart.v and 'Закрыть' or 'Открыть')..u8' рацию департамента', imgui.ImVec2(-1,35.9)) then
					if configuration.main_settings.myrankint >= 0 then
						windows.imgui_depart.v = not windows.imgui_depart.v
					end
				end
				imgui.SameLine()
			end

if settingswindow == 4 then
imgui.Separator()
          imgui.Text(u8'\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t  Основное')
          imgui.Separator()
				if imgui.Button(u8'Что даёт семья?',btn_size) then
					lua_thread.create(function()

			sampSendChat('У нас полная семья с плюшками, которые для тебя дают огромные плюсы.')
			wait(2700)
			sampSendChat('Вы сможете иметь на 1 дом больше, будет доступ к просмотру информационного..')
			wait(2700)
			sampSendChat('..центра через телефон')
			wait(2700)
			sampSendChat('/b Слёты домов/бизнесов можно смотреть через телефон')
			wait(2700)
			sampSendChat('Выход из КПЗ увеличивается в 2 раза, так как у нас самые лучшие адвокаты')
			wait(2700)
			sampSendChat('Также, будет возможность снимать и класть деньги на депозит в любое время.')
			wait(2700)
			sampSendChat('/b Если Вы любите ходить на собиратели, то повысится шанс выпада рулеток.')
			end)
           end
		   	imgui.SameLine()
		    if imgui.Button(u8'Что даёт семья?\n(кратко)',btn_size) then
            lua_thread.create(function()
			sampSendChat('/b Семья даёт кучу привилегий для новичков и не только, есть бренд и галочка.')
			wait(2700)
			sampSendChat('/b Подробней посмотреть можешь в /help > [FAQ] Бренд/галочка для семьи.')
              end)
           end
		   	imgui.SameLine()
          if imgui.Button(u8'Переход к\nнам',btn_size) then
            lua_thread.create(function()
			sampSendChat('Привет, есть к тебе выгодное предложение.')
			wait(2700)
			sampSendChat('Как смотришь на то, чтобы перейти из вашей унылой семьи, в нашу, уже процветающую?')
			wait(2700)
			sampSendChat('У нас частые конкурсы, сбалансированные правила семьи в общем и многое другое. ')
			wait(2700)
			sampSendChat('В нашей семье есть всевозможные улучшения, так что ты ничего не теряешь, а только приобретаешь.')
              end)
           end
		   	if imgui.Button(u8'Пошли к\nнам',btn_size) then
            lua_thread.create(function()
			sampSendChat('Привет, есть к тебе выгодное предложение.')
			wait(2700)
			sampSendChat('Как смотришь на то, чтобы вступить в нашу уже процветающую семью?')
              end)
           end
		   imgui.SameLine()
		   	if imgui.Button(u8'Кричалка\nв /s',btn_size) then
            lua_thread.create(function()
			sampSendChat('/s Принимаю в полную семью от 3-ёх лет в штате! Актив, частые конкурсы и многое другое')
              end)
           end
          imgui.Separator()
          imgui.Text(u8'\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t  Наборы')
          imgui.Separator()
           if	imgui.Button(u8'Набор через /ad',btn_size) then
            lua_thread.create(function()
            sampSetChatInputText('/ad 1 Семья "Tempest" со всеми нашивками ищет дальних родственников. Встреча ')
              end)
           end
           imgui.SameLine()
           if	imgui.Button(u8'Набор через /vr',btn_size) then
               lua_thread.create(function()
            sampSetChatInputText('/vr Семья "Tempest" со всеми нашивками ищет дальних родственников. Встреча ')
              end)
           end
		    imgui.Separator()
          imgui.Text(u8'\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t  Правила')
          imgui.Separator()
           if imgui.Button(u8'Квесты',btn_size) then
            lua_thread.create(function()
            sampSendChat('/fam Минутку внимания!')
            wait(5500)
            sampSendChat('/fam Хотелось бы сказать пару слов про квесты.')
			wait(5500)
            sampSendChat('/fam Выполняя семейные квесты вы получаете:')
			wait(5500)
            sampSendChat('/fam Серебряную рулетку, 16 семейных талонов и 9 EXP')
			wait(6500)
            sampSendChat('/fam Для выполнения трех квестов вам понадобится:')
			wait(6500)
            sampSendChat('/fam Лицензия на авто,ловлю рыбу,плаванье, охоту и любое оружие')
			wait(5500)
            sampSendChat('/fam Зарабатывайте легко в - /gps - Разное (ЖК Аксиома/Ультра/Авантаж)!')
              end)
           end
           imgui.SameLine()
           if	imgui.Button(u8'Ранги',btn_size) then
            lua_thread.create(function()
            sampSendChat('/fam Минутку внимания!')
            wait(5500)
            sampSendChat('/fam В семье работает система рангов.')
            wait(5500)
            sampSendChat('/fam Выполняя семейные квесты вы повышаете свой ранг.')
			wait(5500)
            sampSendChat('/fam Подробнее вы можете узнать в Дискорде семьи.')
			wait(5500)
            sampSendChat('/fam /fammenu - Информация - Discord.')
                end)
           end
		   imgui.SameLine()
           if	imgui.Button(u8'Правила \nнефтебазы',btn_size) then
            lua_thread.create(function()
            sampSendChat('/fam Минутку внимания!')
            wait(5500)
            sampSendChat('/fam Хотелось бы напомнить, что в семье действуют некоторые пункты правил.')
            wait(5500)
            sampSendChat('/fam Один из пунктов касается правилам работы на нефтебазе')
			wait(5500)
            sampSendChat('/fam Люди из нашей семьи, которые крадут бочки и мешают всячески работать..')
			wait(5500)
            sampSendChat('/fam ..обычным игрокам, будут исключены из фамы.')
			wait(5500)
            sampSendChat('/fam Если вы заметили за кем-то нарушение, то..')
			wait(5500)
            sampSendChat('/fam ..просьба написать с док-вами лидеру/заместителю.')
			wait(5500)
            sampSendChat('/fam Не забывайте, что мы должны помогать друг другу, а не пытаться навредить.')
                end)
           end
		   
           if	imgui.Button(u8'Правила \nрекламы',btn_size) then
            lua_thread.create(function()
            sampSendChat('/fam Минутку внимания!')
            wait(5500)
            sampSendChat('/fam Хотелось бы напомнить, что в семье действуют некоторые пункты правил.')
            wait(5500)
            sampSendChat('/fam А если конкретней, то мы заденем рекламу в семейном чате.')
			wait(5500)
            sampSendChat('/fam К самой рекламе относится абсолютно всё, начиная от обычных продаж и..')
			wait(6500)
            sampSendChat('/fam ..заканчивая рекламой своего бизнеса.')
			wait(6500)
            sampSendChat('/fam Рекламировать что-либо в семейный чат можно один раз в 2 минуты.')
			wait(6500)
            sampSendChat('/fam За несоблюдение данного правила игроку будет выдан мут.')
			wait(5500)
            sampSendChat('/fam За неоднократное нарушение этого пункта, игрок будет исключён из семьи.')
                end)
           end
		   imgui.SameLine()
           if	imgui.Button(u8'Попрошайниче-\n-ство ',btn_size) then
            lua_thread.create(function()
            sampSendChat('/fam Минутку внимания!')
            wait(5500)
            sampSendChat('/fam Хотелось бы напомнить, что в семье действуют некоторые пункты правил.')
            wait(5500)
            sampSendChat('/fam Конкретней затронем тему попрошайничества.')
			wait(5500)
            sampSendChat('/fam За любую просьбу что-то дать/подарить, игроку будет выдан мут.')
			wait(5500)
            sampSendChat('/fam За неоднократное нарушение данного пункта правил Вы будете исключены из семьи.')
                end)
           end
		   imgui.SameLine()
		   if	imgui.Button(u8'Неадекватное\nповедение',btn_size) then
            lua_thread.create(function()
            sampSendChat('/fam Минутку внимания!')
            wait(5500)
            sampSendChat('/fam Хотелось бы напомнить, что в семье действуют некоторые пункты правил.')
            wait(5500)
            sampSendChat('/fam Сейчас же мы коснёмся неадекватного поведения.')
			wait(5500)
            sampSendChat('/fam Запрещено оскорблять члена нашей семьи, злоупотреблять матом..')
			wait(5500)
            sampSendChat('/fam ..проявлять различную агрессию в чью-либо сторону')
			wait(5500)
            sampSendChat('/fam Оскорблять администрацию сервера, сам проект, либо же сервер.')
			wait(5500)
            sampSendChat('/fam А также, вести ненормальные(неадекватные) диалоги.')
			wait(5500)
            sampSendChat('/fam Наказание будет выдаваться в зависимости от тяжести нарушения.')
                end)
           end
		   
		   if imgui.Button(u8'Все правила\n(кратко)',btn_size) then
            lua_thread.create(function()
			sampSendChat('/fam В семье запрещено: неадекватное поведение, попрошайничество,')
			wait(5700)
			sampSendChat('/fam Реклама в чат семьи чаще, чем раз в 2 минуты, а также запрещено пиратство.')
              end)
           end
		   imgui.SameLine()
		   if imgui.Button(u8'Безотчётная\nСистема\nПовышения',btn_size) then
            lua_thread.create(function()
			sampSendChat('/fam Внимание! В нашей семье действует безотчётная сис-ма повышений.')
			wait(5700)
			sampSendChat('/fam За обычное общение в семейном чате, частый актив в самой семье.')
			wait(5700)
			sampSendChat('/fam А также какую-либо помощь заместителю/лидеру, вы можете получить повышение.')
              end)
           end
		  imgui.Separator()
          imgui.Text(u8'\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t  Разное')
          imgui.Separator()
		  if imgui.Button(u8'Конференция ВК',btn_size) then
            lua_thread.create(function()
			sampSendChat('/fam Также хотелось бы сказать, что у нас есть собственная конфа в ВК')
			wait(5700)
			sampSendChat('/fam Время от времени там будут проводиться конкурсы, не пропусти и вступай.')
			wait(5700)
			sampSendChat('/fam Ссылку можно найти в нашем дискорд канале, в текстовом разделе: "Информация".')
			wait(5700)
			sampSendChat('/fam Либо же добавить лидера/заместителя в ВК и попросить приглашения в конференцию.')
			wait(5700)
			sampSendChat('/fam ВК зама: vk.com/onligifen ')
			wait(5700)
			sampSendChat('/fam ВК лидера: vk.com/andei_harlamov')
              end)
           end
		  imgui.SameLine()
			if imgui.Button(u8'ВК 9/10',btn_size) then
            lua_thread.create(function()
			sampSendChat('/fam ВК зама: vk.com/onligifen')
			wait(5700)
			sampSendChat('/fam ВК лидера: vk.com/andei_harlamov')
              end)
           end
		  imgui.SameLine()
			if imgui.Button(u8'Ссылка на ДС',btn_size) then
            lua_thread.create(function()
			sampSendChat('/fam Ссылка на дискорд семьи: https://discord.gg/fAEFVBqdTN ')
			wait(5700)
			sampSendChat('/fam Можно скопировать через чатлог, либо писать вручную.')
              end)
           end
			end

			if settingswindow == 5 then
				imgui.PushItemWidth(200)
				if imgui.Combo(u8'Выбор темы', StyleBox_select, StyleBox_arr, #StyleBox_arr) then
					configuration.main_settings.style = StyleBox_select.v
					if inicfg.save(configuration,'SWAT Helper') then
						checkstyle()
					end
				end
				imgui.PopItemWidth()
				if imgui.ColorEdit4(u8'Цвет чата организации##RSet', chatcolors.RChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
					local clr = imgui.ImColor.FromFloat4(chatcolors.RChatColor.v[1], chatcolors.RChatColor.v[2], chatcolors.RChatColor.v[3], chatcolors.RChatColor.v[4]):GetU32()
					configuration.main_settings.RChatColor = clr
					inicfg.save(configuration, 'SWAT Helper.ini')
				end
				imgui.SameLine(imgui.GetWindowWidth() - 75)
				if imgui.Button(u8'Сбросить##RCol',imgui.ImVec2(65,25)) then
					configuration.main_settings.RChatColor = 4282626093
					if inicfg.save(configuration, 'SWAT Helper.ini') then
						chatcolors.RChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.RChatColor):GetFloat4())
					end
				end
				imgui.SameLine(imgui.GetWindowWidth() - 130)
				if imgui.Button(u8'Тест##RTest',imgui.ImVec2(50,25)) then
					local result, myid = sampGetPlayerIdByCharHandle(playerPed)
					local r, g, b, a = imgui.ImColor(configuration.main_settings.RChatColor):GetRGBA()
					sampAddChatMessage('[R] '..configuration.main_settings.myrank..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']:(( Это сообщение видите только вы! ))', join_rgb(r, g, b))
				end
				if imgui.ColorEdit4(u8'Цвет чата департамента##DSet', chatcolors.DChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
					local clr = imgui.ImColor.FromFloat4(chatcolors.DChatColor.v[1], chatcolors.DChatColor.v[2], chatcolors.DChatColor.v[3], chatcolors.DChatColor.v[4]):GetU32()
					configuration.main_settings.DChatColor = clr
					inicfg.save(configuration, 'SWAT Helper.ini')
				end
				imgui.SameLine(imgui.GetWindowWidth() - 75)
				if imgui.Button(u8'Сбросить##DCol',imgui.ImVec2(65,25)) then
					configuration.main_settings.DChatColor = 4294940723
					if inicfg.save(configuration, 'SWAT Helper.ini') then
						chatcolors.DChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.DChatColor):GetFloat4())
					end
				end
				imgui.SameLine(imgui.GetWindowWidth() - 130)
				if imgui.Button(u8'Тест##DTest',imgui.ImVec2(50,25)) then
					local result, myid = sampGetPlayerIdByCharHandle(playerPed)
					local r, g, b, a = imgui.ImColor(configuration.main_settings.DChatColor):GetRGBA()
					sampAddChatMessage('[D] '..configuration.main_settings.myrank..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']: Это сообщение видите только вы!', join_rgb(r, g, b))
				end
				if imgui.ColorEdit4(u8'Цвет SWAT Helper в чате##SSet', chatcolors.ASChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
					local clr = imgui.ImColor.FromFloat4(chatcolors.ASChatColor.v[1], chatcolors.ASChatColor.v[2], chatcolors.ASChatColor.v[3], chatcolors.ASChatColor.v[4]):GetU32()
					configuration.main_settings.ASChatColor = clr
					inicfg.save(configuration, 'SWAT Helper.ini')
				end
				imgui.SameLine(imgui.GetWindowWidth() - 75)
				if imgui.Button(u8'Сбросить##SCol',imgui.ImVec2(65,25)) then
					configuration.main_settings.ASChatColor = 4281558783
					if inicfg.save(configuration, 'SWAT Helper.ini') then
						chatcolors.ASChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.ASChatColor):GetFloat4())
					end
				end
				imgui.SameLine(imgui.GetWindowWidth() - 130)
				if imgui.Button(u8'Тест##ASTest',imgui.ImVec2(50,25)) then
					ASHelperMessage('Это сообщение видите только вы!')
				end
			end

			if settingswindow == 6 then
				imgui.TextColoredRGB('Вы можете добавлять свои правила!{808080} (?)',1)
				imgui.Hint('Вы должны создать .txt файл с кодировкой ANSI\nЛКМ для открытия папки с правилами')
				if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
					createDirectory(getWorkingDirectory()..'\\SWAT Helper\\Rules')
					os.execute('explorer '..getWorkingDirectory()..'\\SWAT Helper\\Rules')
				end
				for i, block in ipairs(ruless) do
					if imgui.Button(u8(block.name), imgui.ImVec2(-1,35)) then
						search_rule.v = ''
						RuleSelect = i
						imgui.OpenPopup(u8('Правила'))
					end
				end
				Rule()
				if imgui.Button(fa.ICON_FA_SPINNER,imgui.ImVec2(25,25)) then
					checkrules()
				end
				imgui.Hint('Нажмите для обновления всех правил')
			end

			if settingswindow == 7 then
				imgui.TextColoredRGB('Автор: {ff6633}Vilgot_Lausen',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Change Log '..(fa.ICON_FA_TERMINAL), imgui.ImVec2(137,30)) then
					windows.imgui_changelog.v = true
				end
				imgui.SameLine()
				if imgui.Button(u8'Check Updates '..(fa.ICON_FA_CLOUD_DOWNLOAD_ALT), imgui.ImVec2(137,30)) then
					lua_thread.create(function ()
						checkbibl()
					end)
				end
				imgui.SetCursorPos(imgui.ImVec2(253,70))
				if imgui.Button(u8'Дополнительно '..(fa.ICON_FA_LAYER_GROUP), imgui.ImVec2(120,25)) then
					imgui.OpenPopup(u8('Остальное'))
				end
				otheractions()
				
		imgui.TextColored(imgui.ImVec4(0.78, 0.082, 0.52, 1), u8'______________________________________________________________________________________________________________________________________')
		imgui.Text(u8"/toset - настройка онлайна")
		imgui.Text(u8"/online - просмотр онлайна за неделю")
		imgui.TextColored(imgui.ImVec4(0.78, 0.082, 0.52, 1), u8'______________________________________________________________________________________________________________________________________')
			imgui.TextColoredRGB('{868686}(Подробнее)')
		imgui.Hint('Чтобы не писать вручную длинную форму,\nдостаточно в строку чата написать например !строй\nи скрипт сам за вас вставит в строку чата форму доклада')
			imgui.InputText('##questeditorques', forma_post)
			imgui.SameLine()
				if imgui.Button('Save##3', imgui.ImVec2(60, 20)) then 
					configuration.main_settings.forma_post = u8:decode(forma_post.v)
					if inicfg.save(configuration, 'SWAT Helper.ini') then 
						ASHelperMessage('Форма сохранена!')
					end
				end
				imgui.TextColored(imgui.ImVec4(0.78, 0.082, 0.52, 1), u8'______________________________________________________________________________________________________________________________________')
			end
			imgui.EndChild()
			imgui.End()
		end

		if windows.imgui_binder.v then
			imgui.SetNextWindowSize(imgui.ImVec2(650, 370), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Биндер', windows.imgui_binder, imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.Image(configuration.main_settings.style ~= 2 and whitebinder or blackbinder,imgui.ImVec2(202,25))
			imgui.SameLine(583)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			if choosedslot then
				if imgui.Button(fa.ICON_FA_QUESTION_CIRCLE,imgui.ImVec2(23,23)) then
					imgui.OpenPopup(u8'Тэги')
				end
			end
			imgui.SameLine(606)
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_binder.v = false
			end
			imgui.PopStyleColor(3)
			bindertags()
			imgui.BeginChild('ChildWindow',imgui.ImVec2(175,270),true, (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
			imgui.SetCursorPosY((imgui.GetWindowWidth() - 160) / 2)
			for key, value in pairs(configuration.BindsName) do
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 160) / 2)
				if imgui.Button(u8(configuration.BindsName[key]),imgui.ImVec2(160,30)) then
					choosedslot = key
					bindersettings.binderbuff.v = u8(configuration.BindsAction[key]):gsub('~', '\n')
					bindersettings.bindername.v = u8(configuration.BindsName[key])
					bindersettings.bindertype.v = u8(configuration.BindsType[key])
					bindersettings.bindercmd.v = u8(configuration.BindsCmd[key])
					binderkeystatus = u8(configuration.BindsKeys[key])
					bindersettings.binderdelay.v = u8(configuration.BindsDelay[key])
				end
			end
			imgui.EndChild()
			if choosedslot ~= nil and choosedslot <= 50 then
				imgui.SameLine()
				imgui.BeginChild('ChildWindow2',imgui.ImVec2(435,200),false)
				imgui.InputTextMultiline(u8'',bindersettings.binderbuff, imgui.ImVec2(435,200))
				imgui.EndChild()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Название бинда:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Название бинда:').y - 115) / 2)
				imgui.Text(u8'Название бинда:'); imgui.SameLine()
				imgui.PushItemWidth(150)
				if choosedslot ~= 50 then imgui.InputText('##bindersettings.bindername', bindersettings.bindername,imgui.InputTextFlags.ReadOnly)
				else imgui.InputText('##bindersettings.bindername', bindersettings.bindername)
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(162)
				imgui.Combo(' ',bindersettings.bindertype, u8'Использовать команду\0Использовать клавиши\0\0', 2)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Название бинда:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Задержка между строками (ms):').y - 50) / 2)
				imgui.TextColoredRGB('Задержка между строками {808080}(ms):'); imgui.SameLine()
				imgui.Hint('Указывайте значение в миллисекундах\n{FFFFFF}1 секунда = 1.000 миллисекунд')
				imgui.PushItemWidth(58)
				imgui.InputText('##bindersettings.binderdelay', bindersettings.binderdelay, imgui.InputTextFlags.CharsDecimal)
				if tonumber(bindersettings.binderdelay.v) and tonumber(bindersettings.binderdelay.v) > 60000 then
					bindersettings.binderdelay.v = '60000'
				elseif tonumber(bindersettings.binderdelay.v) and tonumber(bindersettings.binderdelay.v) < 1 then
					bindersettings.binderdelay.v = '1'
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				if bindersettings.bindertype.v == 0 then
					imgui.Text('/')
					imgui.SameLine()
					imgui.PushItemWidth(147)
					imgui.InputText('##bindersettings.bindercmd',bindersettings.bindercmd,imgui.InputTextFlags.CharsNoBlank)
					imgui.PopItemWidth()
				elseif bindersettings.bindertype.v == 1 then
					if setbinderkey then
						setbinderkey,binderkeystatus = imgui.GetKeys(setbinderkey,2)
					end
					if imgui.Button(binderkeystatus and u8(binderkeystatus) or u8'Нажмите чтобы поменять',imgui.ImVec2(162,24)) then
						if binderkeystatus then
							str = nil
							if binderkeystatus:find('ЛКМ %- сохранение') then
								binderkeystatus = binderkeystatus:match('ЛКМ %- сохранение (.+)')
								setbinderkey = false
							else
								binderkeystatus = nil
								setbinderkey = false
							end
						else
							setbinderkey = true
						end
					end
				end
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 429) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 10) / 2)
				local kei
				local doreplace = false
				if bindersettings.binderbuff.v ~= '' and bindersettings.bindername.v ~= '' and bindersettings.binderdelay.v ~= '' and bindersettings.bindertype.v ~= nil then
					if imgui.Button(u8'Сохранить',imgui.ImVec2(100,30)) then
						if not inprocess then
							if bindersettings.bindertype.v == 0 then
								if bindersettings.bindercmd.v ~= '' and bindersettings.bindercmd.v ~= nil then
									for key, value in pairs(configuration.BindsName) do
										if tostring(u8:decode(bindersettings.bindername.v)) == tostring(value) then
											sampUnregisterChatCommand(configuration.BindsCmd[key])
											doreplace = true
											kei = key
										end
									end
									if doreplace then
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub('\n', '~')
										configuration.BindsName[kei] = u8:decode(bindersettings.bindername.v)
										configuration.BindsAction[kei] = refresh_text
										configuration.BindsDelay[kei] = u8:decode(bindersettings.binderdelay.v)
										configuration.BindsType[kei]= u8:decode(bindersettings.bindertype.v)
										configuration.BindsCmd[kei] = u8:decode(bindersettings.bindercmd.v)
										configuration.BindsKeys[kei] = ''
										if inicfg.save(configuration, 'SWAT Helper') then
											ASHelperMessage('Бинд успешно сохранён!')
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ''
											bindersettings.binderbuff.v = ''
											bindersettings.bindername.v = ''
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ''
											bindersettings.bindercmd.v = ''
											binderkeystatus = nil
											choosedslot = nil
										end
									else
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub('\n', '~')
										table.insert(configuration.BindsName, u8:decode(bindersettings.bindername.v))
										table.insert(configuration.BindsAction, refresh_text)
										table.insert(configuration.BindsDelay, u8:decode(bindersettings.binderdelay.v))
										table.insert(configuration.BindsType, u8:decode(bindersettings.bindertype.v))
										table.insert(configuration.BindsCmd, u8:decode(bindersettings.bindercmd.v))
										table.insert(configuration.BindsKeys, '')
										if inicfg.save(configuration, 'SWAT Helper') then
											ASHelperMessage('Бинд успешно создан!')
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ''
											bindersettings.binderbuff.v = ''
											bindersettings.bindername.v = ''
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ''
											bindersettings.bindercmd.v = ''
											binderkeystatus = nil
											choosedslot = nil
										end
									end
								else
									ASHelperMessage('Вы неправильно указали команду бинда!')
								end
							elseif bindersettings.bindertype.v == 1 then
								if binderkeystatus ~= nil and (u8:decode(binderkeystatus)) ~= 'Нажмите чтобы поменять' and not string.find((u8:decode(binderkeystatus)), 'ЛКМ для сохранения ') and (u8:decode(binderkeystatus)) ~= 'None' then
									for key, value in pairs(configuration.BindsName) do
										if tostring(u8:decode(bindersettings.bindername.v)) == tostring(value) then
											sampUnregisterChatCommand(configuration.BindsCmd[key])
											doreplace = true
											kei = key
										end
									end
									if doreplace then
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub('\n', '~')
										configuration.BindsName[kei] = u8:decode(bindersettings.bindername.v)
										configuration.BindsAction[kei] = refresh_text
										configuration.BindsDelay[kei] = u8:decode(bindersettings.binderdelay.v)
										configuration.BindsType[kei]= u8:decode(bindersettings.bindertype.v)
										configuration.BindsCmd[kei] = ''
										configuration.BindsKeys[kei] = u8(binderkeystatus)
										if inicfg.save(configuration, 'SWAT Helper') then
											ASHelperMessage('Бинд успешно сохранён!')
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ''
											bindersettings.binderbuff.v = ''
											bindersettings.bindername.v = ''
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ''
											bindersettings.bindercmd.v = ''
											binderkeystatus = nil
											choosedslot = nil
										end
									else
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub('\n', '~')
										table.insert(configuration.BindsName, u8:decode(bindersettings.bindername.v))
										table.insert(configuration.BindsAction, refresh_text)
										table.insert(configuration.BindsDelay, u8:decode(bindersettings.binderdelay.v))
										table.insert(configuration.BindsType, u8:decode(bindersettings.bindertype.v))
										table.insert(configuration.BindsKeys, u8(binderkeystatus))
										table.insert(configuration.BindsCmd, '')
										if inicfg.save(configuration, 'SWAT Helper') then
											ASHelperMessage('Бинд успешно создан!')
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ''
											bindersettings.binderbuff.v = ''
											bindersettings.bindername.v = ''
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ''
											bindersettings.bindercmd.v = ''
											binderkeystatus = nil
											choosedslot = nil
										end
									end
								else
									ASHelperMessage('Вы неправильно указали клавишу бинда!')
								end
							end
							updatechatcommands()
						else
							ASHelperMessage('Вы не можете взаимодействовать с биндером во время любой отыгровки!')
						end	
					end
				else
					imgui.LockedButton(u8'Сохранить',imgui.ImVec2(100,30))
					imgui.Hint('Вы ввели не все параметры. Перепроверьте всё.')
				end
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 247) / 2)
				if imgui.Button(u8'Отменить',imgui.ImVec2(100,30)) then
					setbinderkey = false
					keyname = nil
					keyname2 = nil
					bindersettings.bindercmd.v = ''
					bindersettings.binderbuff.v = ''
					bindersettings.bindername.v = ''
					bindersettings.bindertype.v = 0
					bindersettings.binderdelay.v = ''
					bindersettings.bindercmd.v = ''
					binderkeystatus = nil
					updatechatcommands()
					choosedslot = nil
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(230,180))
				imgui.Text(u8'Откройте бинд или создайте новый для меню редактирования.')
			end
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 621) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 10) / 2)
			if imgui.Button(u8'Добавить',imgui.ImVec2(82,30)) then
				choosedslot = 50
				bindersettings.binderbuff.v = ''
				bindersettings.bindername.v = ''
				bindersettings.bindertype.v = 0
				bindersettings.bindercmd.v = ''
				binderkeystatus = nil
				bindersettings.binderdelay.v = ''
				updatechatcommands()
			end
			imgui.SameLine()
			if choosedslot ~= nil and choosedslot ~= 50 then
				if imgui.Button(u8'Удалить',imgui.ImVec2(82,30)) then
					if not inprocess then
						for key, value in pairs(configuration.BindsName) do
							local value = tostring(value)
							if u8:decode(bindersettings.bindername.v) == tostring(configuration.BindsName[key]) then
								sampUnregisterChatCommand(configuration.BindsCmd[key])
								table.remove(configuration.BindsName,key)
								table.remove(configuration.BindsKeys,key)
								table.remove(configuration.BindsAction,key)
								table.remove(configuration.BindsCmd,key)
								table.remove(configuration.BindsDelay,key)
								table.remove(configuration.BindsType,key)
								if inicfg.save(configuration,'SWAT Helper') then
									setbinderkey = false
									keyname = nil
									keyname2 = nil
									bindersettings.bindercmd.v = ''
									bindersettings.binderbuff.v = ''
									bindersettings.bindername.v = ''
									bindersettings.bindertype.v = 0
									bindersettings.binderdelay.v = ''
									bindersettings.bindercmd.v = ''
									binderkeystatus = nil
									choosedslot = nil
									ASHelperMessage('Бинд успешно удалён!')
								end
							end
						end
					updatechatcommands()
					else
						ASHelperMessage('Вы не можете удалять бинд во время любой отыгровки!')
					end
				end
			else
				imgui.LockedButton(u8'Удалить',imgui.ImVec2(82,30))
				imgui.Hint('Выберите бинд который хотите удалить',0)
			end
			imgui.End()
		end

		if windows.imgui_lect.v then 
			imgui.SetNextWindowSize(imgui.ImVec2(435, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Лекции', windows.imgui_lect, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
			imgui.Image(configuration.main_settings.style ~= 2 and whitelection or blacklection,imgui.ImVec2(199,25))
			imgui.SameLine(401)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_lect.v = false
			end
			imgui.PopStyleColor(3)
			imgui.Separator()
			imgui.RadioButton(u8('Чат'), lectionsettings.lection_type, 1)
			imgui.SameLine()
			imgui.RadioButton(u8('/r'), lectionsettings.lection_type, 2)
			imgui.SameLine()
			imgui.RadioButton(u8('/rb'), lectionsettings.lection_type, 3)
			imgui.SameLine()
			imgui.SetCursorPosX(245)
			imgui.PushItemWidth(50)
			if imgui.DragInt('##lectionsettings.lection_delay', lectionsettings.lection_delay, 1, 1, 30, u8('%0.0f с.')) then
				if lectionsettings.lection_delay.v < 1 then lectionsettings.lection_delay.v = 1 end
				if lectionsettings.lection_delay.v > 30 then lectionsettings.lection_delay.v = 30 end
				configuration.main_settings.lection_delay = lectionsettings.lection_delay.v
				inicfg.save(configuration,'SWAT Helper')
				end
			imgui.Hint('Задержка между сообщениями')
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(307)
			if imgui.Button(u8'Создать новую '..fa.ICON_FA_PLUS_CIRCLE, imgui.ImVec2(112, 24)) then
				lection_number = nil
				lectionsettings.lection_name.v = u8('')
				lectionsettings.lection_text.v = u8('')
				imgui.OpenPopup(u8('Редактор рекламы'))
			end
			imgui.Separator()
			if #lections.data == 0 then
				imgui.SetCursorPosY(120)
				imgui.TextColoredRGB('У вас нет ни одной лекции.',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 250) / 2)
				if imgui.Button(u8'Восстановить изначальные лекции', imgui.ImVec2(250, 25)) then
					lections = default_lect
					local file = io.open(getWorkingDirectory()..'\\SWAT Helper\\Lections.json', 'w')
					file:write(encodeJson(lections))
					file:close()
				end
			else
				for i, block in ipairs(lections.data) do
					if lections.active.bool == true then
						if block.name == lections.active.name then
							if imgui.Button(fa.ICON_FA_PAUSE..'##'..u8(block.name), imgui.ImVec2(280, 25)) then
								inprocess = false
								lections.active.bool = false
								lections.active.name = nil
								lections.active.handle:terminate()
								lections.active.handle = nil
							end
						else
							imgui.LockedButton(u8(block.name), imgui.ImVec2(280, 25))
						end
						imgui.SameLine()
						imgui.LockedButton(fa.ICON_FA_PEN..'##'..u8(block.name), imgui.ImVec2(50, 25))
						imgui.SameLine()
						imgui.LockedButton(fa.ICON_FA_TRASH..'##'..u8(block.name), imgui.ImVec2(50, 25))
					else
						if imgui.Button(u8(block.name), imgui.ImVec2(280, 25)) then
							lections.active.bool = true
							lections.active.name = block.name
							lections.active.handle = lua_thread.create(function()
								inprocess = true
								for i, line in ipairs(block.text) do
									if lectionsettings.lection_type.v == 2 then
										sampSendChat(('/r %s'):format(line))
									elseif lectionsettings.lection_type.v == 3 then
										sampSendChat(('/rb %s'):format(line))
									elseif lectionsettings.lection_type.v == 4 then
										sampSendChat(('/s %s'):format(line))
									else
										sampSendChat(line)
									end
									if i ~= #block.text then
										wait(lectionsettings.lection_delay.v * 1000)
									end
								end
								inprocess = false
								lections.active.bool = false
								lections.active.name = nil
								lections.active.handle = nil
							end)
						end
						imgui.SameLine()
						if imgui.Button(fa.ICON_FA_PEN..'##'..u8(block.name), imgui.ImVec2(50, 25)) then
							lection_number = i
							lectionsettings.lection_name.v = u8(tostring(block.name))
							lectionsettings.lection_text.v = u8(tostring(table.concat(block.text, '\n')))
							imgui.OpenPopup(u8'Редактор лекций')
						end
						imgui.SameLine()
						if imgui.Button(fa.ICON_FA_TRASH..'##'..u8(block.name), imgui.ImVec2(50, 25)) then
							lection_number = i
							imgui.OpenPopup('##delete')
						end
					end
				end
			end
			if imgui.BeginPopup('##delete') then
				imgui.TextColoredRGB('Вы уверены, что хотите удалить лекцию \n\''..(lections.data[lection_number].name)..'\'',1)
				imgui.SetCursorPosX( (imgui.GetWindowWidth() - 100 - imgui.GetStyle().ItemSpacing.x) / 2 )
				if imgui.Button(u8'Да',imgui.ImVec2(50,25)) then
					imgui.CloseCurrentPopup()
					table.remove(lections.data, lection_number)
					local file = io.open(getWorkingDirectory()..'\\SWAT Helper\\Lections.json', 'w')
					file:write(encodeJson(lections))
					file:close()
				end
				imgui.SameLine()
				if imgui.Button(u8'Нет',imgui.ImVec2(50,25)) then
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			editlection()
			imgui.End()
		end

		if windows.imgui_depart.v then 
			imgui.SetNextWindowSize(imgui.ImVec2(700, 365), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'#depart', windows.imgui_depart, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			imgui.Image(configuration.main_settings.style ~= 2 and whitedepart or blackdepart,imgui.ImVec2(266,25))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			imgui.SameLine(645)
			if imgui.Button(fa.ICON_FA_MINUS_SQUARE,imgui.ImVec2(23,23)) then
				if #dephistory ~= 0 then
					dephistory = {}
					ASHelperMessage('История сообщений успешно очищена.')
				end
			end
			imgui.Hint('Очистить историю сообщений')
			imgui.SameLine(668)
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_depart.v = false
			end
			imgui.PopStyleColor(3)
			imgui.BeginChild('##depbuttons',imgui.ImVec2(180,300),true)
			imgui.PushItemWidth(150)
			imgui.TextColoredRGB('Тэг вашей организации',1)
			if imgui.InputText('##myorgnamedep',departsettings.myorgname) then
				configuration.main_settings.astag = u8:decode(departsettings.myorgname.v)
			end
			if not imgui.IsItemActive() and #departsettings.myorgname.v == 0 then
				imgui.SameLine(20.7)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8('SWAT'))
			end
			imgui.TextColoredRGB('Тэг с кем связываетесь',1)
			imgui.InputText('##toorgnamedep',departsettings.toorgname)
			if not imgui.IsItemActive() and #departsettings.toorgname.v == 0 then
				imgui.SameLine(20.7)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8('LSa'))
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('##deptext',imgui.ImVec2(480,265),true,imgui.WindowFlags.NoScrollbar)
			imgui.SetScrollY(imgui.GetScrollMaxY())
			imgui.TextColoredRGB('История сообщений департамента {808080}(?)',1)
			imgui.Hint('Если в чате департамента будет тэг \''..u8:decode(departsettings.myorgname.v)..'\'\n{FFFFFF}в этот список добавится это сообщение')
			imgui.Separator()
			for k,v in pairs(dephistory) do
				imgui.TextWrapped(u8(v))
			end
			imgui.EndChild()
			imgui.SetCursorPos(imgui.ImVec2(207,323))
			imgui.PushItemWidth(368)
			imgui.InputText('##myorgtextdep',departsettings.myorgtext)
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Button(u8'Отправить',imgui.ImVec2(100,24)) then
				if u8:decode(departsettings.myorgname.v) ~= '' and u8:decode(departsettings.toorgname.v) ~= '' and u8:decode(departsettings.myorgtext.v) ~= '' then
					if u8:decode(departsettings.frequency.v) == '' then
						sampSendChat(('/d [%s] - [%s] %s'):format(u8:decode(departsettings.myorgname.v),u8:decode(departsettings.toorgname.v),u8:decode(departsettings.myorgtext.v)))
					else
						sampSendChat(('/d [%s] - %s - [%s] %s'):format(u8:decode(departsettings.myorgname.v),u8:decode(departsettings.frequency.v):gsub('%.',','),u8:decode(departsettings.toorgname.v),u8:decode(departsettings.myorgtext.v)))
					end
					departsettings.myorgtext.v = ''
				else
					ASHelperMessage('У вас что-то не указано.')
				end
			end
			if #departsettings.myorgtext.v == 0 then
				imgui.SameLine(212)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8'Напишите сообщение')
			end
			imgui.End()
		end

		if windows.imgui_changelog.v then
			imgui.SetNextWindowSize(imgui.ImVec2(900, 700), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'##changelog', windows.imgui_changelog, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
			imgui.Image(configuration.main_settings.style ~= 2 and whitechangelog or blackchangelog,imgui.ImVec2(238,25))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			imgui.SameLine(868)
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_changelog.v = false
			end
			imgui.PopStyleColor(3)
			imgui.Separator()
			imgui.PushFont(fontsize16)
			imgui.TextColoredRGB([[
Версия 1.1(текущая)
 - Добавлено быстрое меню.
 - Добавлен биндер.
 - Обновлено меню.
 - Правила использования рации департамента перенесено в быстрое меню.
 - Добавлена автоматическая проверка документов на собеседовании.
 - Обновлён список настроек меню, пользователя.
 - Добавлено использование рации департамента.
 - Фикс багов.
 
Версия 1.0
 - Релиз
]])
			imgui.PopFont()
			imgui.End()
		end

		if windows.imgui_stats.v then
			imgui.SetNextWindowSize(imgui.ImVec2(150, 175), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(configuration.imgui_pos.posX,configuration.imgui_pos.posY),imgui.Cond.FirstUseEver)
			imgui.Begin(u8'Статистика  ##stats',_,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
			if imgui.IsMouseDoubleClicked(0) and imgui.IsWindowHovered() then
				local pos = imgui.GetWindowPos()
				configuration.imgui_pos.posX = pos.x
				configuration.imgui_pos.posY = pos.y
				if inicfg.save(configuration, 'SWAT Helper.ini') then
					ASHelperMessage('Позиция была сохранена.')
				end
			end
			
			imgui.End()
		end
	end
end

function getClosestPlayerId()
	local temp = {}
	local tPeds = getAllChars()
	local me = {getCharCoordinates(playerPed)}
	for i, ped in ipairs(tPeds) do 
		local result, id = sampGetPlayerIdByCharHandle(ped)
		if ped ~= playerPed and result then
			local pl = {getCharCoordinates(ped)}
			local dist = getDistanceBetweenCoords3d(me[1], me[2], me[3], pl[1], pl[2], pl[3])
			temp[#temp + 1] = { dist, id }
		end
	end
	if #temp > 0 then
		table.sort(temp, function(a, b) return a[1] < b[1] end)
		return true, temp[1][2]
	end
	return false
end

function checkrules()
	if lfscheck then
		local files = 0
		ruless = {}
		for line in lfs.dir(getWorkingDirectory()..'\\SWAT Helper\\Rules') do
			if line == nil then
			elseif line:match('.+%.txt') then
				files = files + 1
				local temp = io.open(getWorkingDirectory()..'\\SWAT Helper\\Rules\\'..line:match('.+%.txt'), 'r+')
				local temptable = {}
				for linee in temp:lines() do
					if linee == '' then
						table.insert(temptable,' ')
					else
						table.insert(temptable,linee)
					end
				end
				table.insert(ruless,{
					name = line:match('(.+)%.txt'),
					text = temptable
				})
				temp:close()
			end
		end
		if files == 0 then
			ruless = default_rules
			for i, block in ipairs(ruless) do
				local temp = io.open(getWorkingDirectory()..'\\SWAT Helper\\Rules\\'..block.name..'.txt', 'w')
				for _,line in ipairs(block.text) do
					temp:write(line..'\n')
				end
				temp:close()
			end
		end
	end
end

function checkbibl()
	local doupdate = nil
	local function DownloadFile(url, file)
		downloadUrlToFile(url,file,function(id,status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			end
		end)
		while not doesFileExist(file) do
			wait(1000)
		end
		ASHelperMessage('Скачиваю...')
	end
	createDirectory(getWorkingDirectory()..'\\SWAT Helper')
	createDirectory(getWorkingDirectory()..'\\SWAT Helper\\Rules')
	if not doesFileExist(getWorkingDirectory()..'\\SWAT Helper\\Lections.json') then
		lections = default_lect
		local file = io.open(getWorkingDirectory()..'\\SWAT Helper\\Lections.json', 'w')
		file:write(encodeJson(lections))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\SWAT Helper\\Lections.json', 'r')
		lections = decodeJson(file:read('*a'))
		file:close()
	end
	if not doesFileExist(getWorkingDirectory()..'\\SWAT Helper\\Questions.json') then
		questions = default_questions
		local file = io.open(getWorkingDirectory()..'\\SWAT Helper\\Questions.json', 'w')
		file:write(encodeJson(questions))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\SWAT Helper\\Questions.json', 'r')
		questions = decodeJson(file:read('*a'))
		questions.active.redact = false
		file:close()
	end
	checkrules()
	if not imguicheck then
		ASHelperMessage('Отсутствует библиотека imgui. Пытаюсь её установить.')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/MoonImGui.dll', 'moonloader/lib/MoonImGui.dll')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/imgui.lua', 'moonloader/lib/imgui.lua')
		ASHelperMessage('Библиотека imgui была успешно установлена.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not sampevcheck then
		ASHelperMessage('Отсутствует библиотека samp events. Пытаюсь её установить.')
		createDirectory('moonloader/lib/samp')
		createDirectory('moonloader/lib/samp/events')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events.lua', 'moonloader/lib/samp/events.lua')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/raknet.lua', 'moonloader/lib/samp/raknet.lua')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/synchronization.lua', 'moonloader/lib/samp/synchronization.lua')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/bitstream_io.lua', 'moonloader/lib/samp/events/bitstream_io.lua')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/core.lua', 'moonloader/lib/samp/events/core.lua')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/extra_types.lua', 'moonloader/lib/samp/events/extra_types.lua')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/handlers.lua', 'moonloader/lib/samp/events/handlers.lua')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/utils.lua', 'moonloader/lib/samp/events/utils.lua')
		ASHelperMessage('Библиотека samp events была успешно установлена.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not encodingcheck then
		ASHelperMessage('Отсутствует библиотека encoding. Пытаюсь её установить.')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/encoding.lua', 'moonloader/lib/encoding.lua')
		ASHelperMessage('Библиотека encoding была успешно установлена.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not lfscheck then
		ASHelperMessage('Отсутствует библиотека lfs. Пытаюсь её установить.')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/lfs.dll','moonloader/lib/lfs.dll')
		ASHelperMessage('Библиотека lfs была успешно установлена.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
		ASHelperMessage('Отсутствует файл шрифта. Пытаюсь его установить.')
		createDirectory('moonloader/resource/fonts')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/fa-solid-900.ttf', 'moonloader/resource/fonts/fa-solid-900.ttf')
		ASHelperMessage('Файл шрифта был успешно установлен.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not doesFileExist('moonloader/SWAT Helper/Images/binderblack.png') or not doesFileExist('moonloader/SWAT Helper/Images/binderwhite.png') or not doesFileExist('moonloader/SWAT Helper/Images/lectionblack.png') or not doesFileExist('moonloader/SWAT Helper/Images/lectionwhite.png') or not doesFileExist('moonloader/SWAT Helper/Images/settingsblack.png') or not doesFileExist('moonloader/SWAT Helper/Images/settingswhite.png') or not doesFileExist('moonloader/SWAT Helper/Images/changelogblack.png') or not doesFileExist('moonloader/SWAT Helper/Images/changelogwhite.png') or not doesFileExist('moonloader/SWAT Helper/Images/departamentblack.png') or not doesFileExist('moonloader/SWAT Helper/Images/departamenwhite.png') then
		ASHelperMessage('Отсутствуют PNG файлы. Пытаюсь их скачать.')
		createDirectory('moonloader/SWAT Helper/Images')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/binderblack.png', 'moonloader/SWAT Helper/Images/binderblack.png')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/binderwhite.png', 'moonloader/SWAT Helper/Images/binderwhite.png')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/lectionblack.png', 'moonloader/SWAT Helper/Images/lectionblack.png')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/lectionwhite.png', 'moonloader/SWAT Helper/Images/lectionwhite.png')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/settingsblack.png', 'moonloader/SWAT Helper/Images/settingsblack.png')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/settingswhite.png', 'moonloader/SWAT Helper/Images/settingswhite.png')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/departamentblack.png', 'moonloader/SWAT Helper/Images/departamentblack.png')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/departamenwhite.png', 'moonloader/SWAT Helper/Images/departamenwhite.png')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/changelogblack.png', 'moonloader/SWAT Helper/Images/changelogblack.png')
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/735553fd8990b6a52900927e26e6cfc087eda065/changelogwhite.png', 'moonloader/SWAT Helper/Images/changelogwhite.png')
		ASHelperMessage('PNG файлы успешно скачаны.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if doesFileExist('moonloader/updateswathelperr.ini') then
		os.remove('moonloader/updateswathelperr.ini')
	end
	downloadUrlToFile('https://raw.githubusercontent.com/ozr1236/swat/main/updateswathelperr.ini', 'moonloader/updateswathelperr.ini', function(id, status)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist('moonloader/updateswathelperr.ini') then
				local updates = io.open('moonloader/updateswathelperr.ini','r')
				local tempdata = {}
				for line in updates:lines() do
					table.insert(tempdata, line)
				end
				io.close(updates)
				if tonumber(tempdata[1]) > thisScript().version_num then
					ASHelperMessage('Найдено обновление. Пытаюсь установить его.')
					doupdate = true
					configuration.main_settings.changelog = true
					inicfg.save(configuration, 'SWAT Helper.ini')
				else
					ASHelperMessage('Обновлений не найдено.')
					doupdate = false
				end
				os.remove('moonloader/updateswathelperr.ini')
			else
				ASHelperMessage('Произошла ошибка во время проверки обновлений.')
			end
		end
	end)
	while doupdate == nil do
		wait(300)
	end
	if doupdate then
		DownloadFile('https://raw.githubusercontent.com/ozr1236/swat/main/SWAT%20Helperr.lua', thisScript().path)
		NoErrors = true
		ASHelperMessage('Обновление успешно установлено.')
		return false
	end
	return true
end