-- Copyright © 2008-2019 Pioneer Developers. See AUTHORS.txt for details
-- Licensed under the terms of the GPL v3. See licenses/GPL-3.txt

--
-- Interface: NameGen
--
-- Functions for generating names.
--

local Engine = import("Engine")

local r = function (t, rand) return t[rand:Integer(1,#t)] end

local NameGen
NameGen = {
	firstNames = {
		male   = {},
		female = {},
	},
	surnames = {},

	outdoorPlanetFormats = {},
	rockPlanetFormats = {},

	orbitalStarportFormats = {},
	surfaceStarportFormats = {},

--
-- Function: FullName
--
-- Create a full name (first + surname) string
--
-- > name = Namegen.FullName(isfemale, rand)
--
-- Parameters:
--
--   isfemale - whether to generate a male or female name. true for female,
--              false for male
--
--   rand - optional, the <Rand> object to use to generate the name. if
--          omitted, <Engine.rand> will be used
--
-- Return:
--
--   name - a string containing the name
--
-- Availability:
--
--   alpha 10
--
-- Status:
--
--   stable
--

	FullName = function (isfemale, rand)
		if not rand then rand = Engine.rand end

		local firstname
		if isfemale then
			firstname = r(NameGen.firstNames.female, rand)
		else
			firstname = r(NameGen.firstNames.male, rand)
		end

		return firstname .. " " .. NameGen.Surname(rand)
	end,

--
-- Function: Surname
--
-- Create a surname string
--
-- > name = Namegen.Surname(rand)
--
-- Parameters:
--
--   rand - optional, the <Rand> object to use to generate the name. if
--          omitted, <Engine.rand> will be used
--
-- Return:
--
--   name - a string containing the name
--
-- Availability:
--
--   alpha 10
--
-- Status:
--
--   stable
--

	Surname = function (rand)
		if not rand then rand = Engine.rand end

		return r(NameGen.surnames, rand)
	end,

--
-- Function: BodyName
--
-- Create a planet name
--
-- > name = Namegen.BodyName(body, rand)
--
-- Parameters:
--
--   body - the <SystemBody> object to provide a name for. Currently must of type
--          STARPORT_ORBITAL, STARPORT_SURFACE or ROCKY_PLANET. Any other types
--          a Lua error.
--
--   rand - optional, the <Rand> object to use to generate the name. if
--          omitted, <Engine.rand> will be used
--
-- Return:
--
--   name - a string containing the name
--
-- Availability:
--
--   alpha 19
--
-- Status:
--
--   experimental
--
	BodyName = function (body, rand)
		if not rand then rand = Engine.rand end

		if body.type == "STARPORT_ORBITAL" then
			return string.interp(r(NameGen.orbitalStarportFormats, rand), { name = NameGen.Surname(rand) })
		end

		if body.type == "STARPORT_SURFACE" then
			return string.interp(r(NameGen.surfaceStarportFormats, rand), { name = NameGen.Surname(rand) })
		end

		if body.superType == "ROCKY_PLANET" then

			-- XXX -15-50C is "outdoor". once more planet composition
			-- attributes are exposed we can do better here
			if body.averageTemp >= 258 and body.averageTemp <= 323 then
				return string.interp(r(NameGen.outdoorPlanetFormats, rand), { name = NameGen.Surname(rand) })
			end

			return string.interp(r(NameGen.rockPlanetFormats, rand), { name = NameGen.Surname(rand) })
		end

		error("No available namegen for body type '" .. body.type .. "'")
	end
}

NameGen.firstNames.male = {
	'Aaron', 'Abram', 'Adam', 'Adrian', 'Agustin', 'Alan', 'Albert', 'Alberto',
	'Alejandro', 'Alessandro', 'Alex', 'Alexander', 'Alfonso', 'Alfredo',
	'Alistair', 'Andres', 'Andrew', 'Angel', 'Antonio', 'Antti', 'Arda', 'Arthur',
	'Asier', 'Barry', 'Ben', 'Benjamin', 'Benoit', 'Bernard', 'Bill',
	'Blaga', 'Bob', 'Brian', 'Bruce', 'Byron', 'Carl', 'Carlos', 'Chip',
	'Chris', 'Christopher', 'Clive', 'Connor', 'Craig', 'Dan', 'Daniel', 'Darren',
	'Dave', 'David', 'Denis', 'Dennis', 'Derek', 'Diego', 'Dmitry', 'Dionisis', 'Domingo', 'Donald',
	'Eduardo', 'Eliott', 'Emery', 'Emilio', 'Enric', 'Enrique', 'Eren', 'Felipe', 'Felix',
	'Fernando', 'Florian', 'Fran', 'Francisco', 'Francisco Javier', 'Frank',
	'Gareth', 'Gary', 'Gaz', 'Gene', 'Geoffrey', 'George', 'Gernot', 'Graham', 'Gregorio',
	'Guy', 'Henry', 'Herbert', 'Ian', 'Ignacio', 'Isaac', 'Jackie', 'Jaime',
	'Jake', 'James', 'Jan', 'Javier', 'Jeremy', 'Jesus', 'Jim', 'Jimmy',
	'Joaquin', 'John', 'Jorge', 'Jose', 'Jose Antonio', 'Jose Luis',
	'Jose Manuel', 'Jose Maria', 'Jose Ramon', 'Josh', 'Juan',
	'Antonio', 'Juan Carlos', 'Juan Jose', 'Juan Manuel', 'Julian', 'Karl',
	'Keith', 'Kenneth', 'Kimmo', 'Konrad', 'Krzysztof', 'Lance', 'Lars',
	'Lee', 'Leon', 'Leonardo', 'Luca', 'Luis', 'Maksim', 'Malcolm', 'Manuel',
	'Marcel', 'Marcus', 'Mariano', 'Mark', 'Matthew', 'Mete', 'Michael',
	'Michele', 'Miguel', 'Miha', 'Morgan', 'Muhammad', 'Neil', 'Nic', 'Nick', 'Nicholas', 'Non', 'Oleg', 'Pablo', 'Patrick',
	'Paul', 'Pedro', 'Peter', 'Phil', 'Philip', 'Piotr', 'Radek', 'Rafael',
	'Ralph', 'Ramon', 'Rémi', 'Ricardo', 'Richard', 'Rob', 'Robert', 'Roger', 'Roland',
	'Roy', 'Salvador', 'Santiago', 'Sean', 'Sergey', 'Simon', 'Stefan', 'Stephen',
	'Steve', 'Subaru', 'Sung', 'Szilárd', 'Taiki', 'Teoman', 'Thierry', 'Thomas', 'Tim', 'Timothy', 'Tom', 'Tomas', 'Tony',
	'Tristram', 'Ulf', 'Vaughan', 'Vincent', 'Vladimir', 'Wayne', 'Wernher', 'Will', 'William', 'Xi',
	'Yeong', 'Yuri',
}
-- SAVEBUMP add:

NameGen.firstNames.female = {
	'Jen', 'Steph', 'Hannah', 'Alison', 'Amanda', 'Angela', 'Ann', 'Anne', 'Ashley',
	'Audrey', 'Barbara', 'Beryl', 'Betty', 'Beth', 'Beyza', 'Brenda', 'Carol',
	'Caroline', 'Catherine', 'Cathy', 'Celia', 'Cheryl', 'Christine', 'Claire',
	'Daphne', 'Diana', 'Dorothy', 'Elise', 'Elaine', 'Edith', 'Emma', 'Ella',
	'Erica', 'Esther', 'Eva', 'Fran', 'Frances', 'Fiona', 'Gill', 'Gillian',
	'Hazel', 'Heather', 'Helen', 'Hilary', 'Irena', 'Isobel', 'Jane', 'Janet',
	'Janice', 'Jeanette', 'Jenny', 'Jennifer', 'Jill', 'Jo', 'Joan', 'Joanna',
	'Joy', 'Juliette', 'Judy', 'Julia', 'Kara', 'Karen', 'Kate', 'Kathy', 'Katherine',
	'Laura', 'Linda', 'Lisa', 'Louise', 'Lucy', 'Luna', 'Maggie', 'Margaret',
	'Maria', 'Mariam', 'Marilyn', 'Marion', 'Maureen', 'Melis', 'Molly', 'Miriam',
	'Morag', 'Monica', 'Nat', 'Natalia', 'Nicola', 'Nuan', 'Pam', 'Pamela', 'Patricia',
	'Pauline', 'Penny', 'Rachel', 'Rose', 'Rosemary', 'Rosie', 'Sally',
	'Sandra', 'Sarah', 'Stella', 'Sue', 'Sally', 'Susan', 'Susanne', 'Suzy',
	'Tracy', 'Valerie', 'Vicky', 'Vivian', 'Violet', 'Wendy', 'Yvonne', 'Zoe',
	'Maria', 'Carmen', 'Josefa', 'Isabel', 'Dolores', 'Francisca', 'Antonia',
	'Pilar', 'Ana Maria', 'Ana', 'Maria Luisa', 'Mercedes', 'Manuela', 'Juana',
	'Rosario', 'Tanaka', 'Teresa', 'Maria Jose', 'Margarita', 'Maria Angeles', 'Angeles',
	'Maria Pilar',
}

NameGen.surnames = {
	'Acevedo', 'Adams', 'Aguilar', 'Aguirre', 'Albert', 'Alexander',
	'Alford', 'Allen', 'Allnutt', 'Alston', 'Alvarez', 'Anderson',
	'Andrews', 'Armstrong', 'Arnold', 'Ashley', 'Ashworth', 'Asimov', 'Atkinson', 'Austin',
	'Avery', 'Bailey', 'Baird', 'Baker', 'Ashworth', 'Bálint', 'Banks', 'Barlow', 'Barnes',
	'Barron', 'Barry', 'Bartholomew', 'Basagoiti', 'Bean', 'Bell',
	'Bender', 'Benjamin', 'Bennet', 'Bennett', 'Bentley', 'Berg',
	'Berger', 'Bernard', 'Berry', 'Best', 'Bishop', 'Black', 'Blackburn',
	'Blanchard', 'Blevins', 'Bolton', 'Bonner', 'Botticelli', 'Boutemy', 'Boyd',
	'Boyle', 'Branch', 'Bray', 'Brennan', 'Briggs', 'Bright', 'Britt', 'Brooks',
	'Brown', 'Bryant', 'Buckley', 'Buckner', 'Bumgardner', 'Burch',
	'Burks', 'Burns', 'Burris', 'Burton', 'Butcher', 'Butler', 'Byers',
	'Cabrera', 'Calderon', 'Campbell', 'Campos', 'Cantrell', 'Cardenas',
	'Carney', 'Carpenter', 'Carr', 'Carrol', 'Carter', 'Carver', 'Case',
	'Castillo', 'Castropena', 'Cervantes', 'Chan', 'Chandler', 'Chaney',
	'Chang', 'Chao', 'Chapman', 'Chavez', 'Chen', 'Cheng', 'Cherry',
	'Chia', 'Chiang', 'Chin', 'Chopin', 'Chou', 'Chu', 'Chung', 'Church', 'Clarke',
	'Clements', 'Clemons', 'Cleveland', 'Cole', 'Coleman', 'Collin', 'Collins',
	'Compton', 'Conrad', 'Cook', 'Cooke', 'Cooley', 'Cooper', 'Copland',
	'Cosmin', 'Cote', 'Cotton', 'Cox', 'Craft', 'Crane', 'Crawford',
	'Crosby', 'Cruz', 'Cunningham', 'Daniels', 'Daugherty', 'Davidson',
	'Davis', 'de Craen', 'De La Cruz', 'de Roos', 'Dean', 'Dennett',
	'Diaz', 'Dickson', 'Dillard', 'Dillon', 'Dixon', 'Donaldson',
	'Donovan', 'Dotson', 'Dudley', 'Duke', 'Duncan', 'Dunlap', 'Dunn',
	'Dupré', 'Dyson', 'Edwards', 'Elliott', 'Ellis', 'Emerson', 'Espinoza',
	'Estes', 'Evans', 'Ewing', 'Fan', 'Fang', 'Farley', 'Farrell',
	'Faulkner', 'Feng', 'Ferguson', 'Fernandez', 'Ferrel', 'Fields',
	'Findley', 'Finley', 'Fisher', 'Fitzpatrick', 'Flores', 'Fogelmark', 'Foley',
	'Forbes', 'Ford', 'Foster', 'Fox', 'Franco', 'Franklin', 'Frederick',
	'Freeman', 'Frost', 'Fry', 'Frye', 'Fuentes', 'Fuller', 'Fulton', 'Gagarin',
	'Galloway', 'Gamble', 'Ganzerla', 'Garcia', 'Gardner', 'Garza', 'Gay', 'George',
	'Giachi', 'Gibbs', 'Gibson', 'Gilbert', 'Giles', 'Gimeno', 'Glark', 'Goff',
	'Gomez', 'Gonzales', 'Gonzalez', 'Goodwin', 'Gordon', 'Gould',
	'Graham', 'Grant', 'Gray', 'Gredka', 'Green', 'Greene', 'Griffin',
	'Guerra', 'Guthrie', 'Gutierrez', 'Hahn', 'Haley', 'Hall', 'Hamilton',
	'Han', 'Hansen', 'Hao', 'Hard', 'Harding', 'Hardy', 'Harper',
	'Harris', 'Harrison', 'Harvey', 'Hawkins', 'Hayden', 'Hays', 'Hemingway',
	'Henderson', 'Hendricks', 'Hendrix', 'Henry', 'Herbert', 'Herman',
	'Hernandez', 'Hester', 'Hicks', 'Hill', 'Hills', 'Hindle', 'Hinton', 'Hodgetts',
	'Holden', 'Holman', 'Holmes', 'Hooper', 'Hopper', 'Horne', 'Hou',
	'Howard', 'Howe', 'Howell', 'Howlett', 'Hsai', 'Hsiao', 'Hsieh',
	'Hsiung', 'Hsu', 'Hu', 'Huang', 'Hubble', 'Huber', 'Hudson', 'Hughes', 'Hung',
	'Hunt', 'Hunter', 'Hurley', 'Hurst', 'Ibarrez', 'Irwin', 'Jackson',
	'Jacobs', 'Jacobson', 'James', 'Jarvis', 'Jenkins', 'Johnson',
	'Johnston', 'Jones', 'Jordan', 'Joyce', 'Joyner', 'Juarez', 'Justice',
	'Kane', 'Kang', 'Kao', 'Kapusniak', 'Kelley', 'Kelly', 'Kennedy',
	'Kerr', 'Key', 'Khrushchev', 'Kidd', 'Kim', 'King', 'Kinney', 'Kirkland', 'Kline',
	'Klippenberg', 'Knapp', 'Knight', 'Koch', 'Kontominas', 'Kotajärvi', 'Kranz',
	'Kulikov', 'Kung', 'Kuo', 'Kurucz', 'Lancaster', 'Lane', 'Langley',
	'Larson', 'Lawrence', 'Lawson', 'Lee', 'Lei', 'Levine', 'Levy',
	'Lewis', 'Li', 'Liang', 'Liao', 'Lin', 'Little', 'Liu', 'Livingston',
	'Lo', 'Long', 'Lopez', 'Lowery', 'Lucas', 'Lung', 'Lynch', 'Ma',
	'Macdonald', 'Macias', 'Madden', 'Mahol', 'Manna', 'Manley', 'Mao', 'Marakasov', 'Marshall',
	'Martin', 'Martinez', 'Mas', 'Mason', 'Matthews', 'Maxwell', 'Mayer',
	'Maynard', 'Mayo', 'Mays', 'Mcconnell', 'Mccoy', 'Mccray',
	'Mccullough', 'Mcdonald', 'Mcfadden', 'Mcfarland', 'Mcgowan',
	'Mcintosh', 'Mckay', 'Mcleod', 'Mcmillan', 'Mcneil', 'Mcpherson',
	'Meadows', 'Mejia', 'Melendez', 'Mercer', 'Merrill', 'Meyer',
	'Middleton', 'Miles', 'Miller', 'Mills', 'Miranda', 'Mitchell',
	'Montgomery', 'Moon', 'Mooney', 'Moore', 'Morales', 'Morgan', 'Morin',
	'Morris', 'Morrison', 'Morse', 'Morton', 'Moss', 'Mruk', 'Mullen',
	'Munoz', 'Murphy', 'Murray', 'Musk', 'Myers', 'Neil', 'Nelson', 'Newton',
	'Nichols', 'Niedźwiecki', 'Nielsen', 'Niu', 'Nixon', 'Noel', 'Nolan',
	'Norris', 'Ochoa', 'Odom', 'Odonnell', 'Oliver', 'Olsina', 'Olson',
	'Oneill', 'Ortiz', 'Osborn', 'Ovcharenko', 'Owens', 'Ozmen', 'Pallier', 'Palmer', 'Pan', 'Parker',
	'Patterson', 'Payne', 'Peck', 'Pennington', 'Perez', 'Perry',
	'Peters', 'Peterson', 'Pettersson', 'Phillips', 'Pickett', 'Pierce',
	'Porter', 'Potts', 'Powell', 'Powers', 'Pretty', 'Price', 'Qing', 'Ramirez',
	'Ramos', 'Rasmussen', 'Ray', 'Raymond', 'Reed', 'Reese', 'Reid',
	'Reilly', 'Reyes', 'Reynolds', 'Rhodes', 'Rice', 'Richards',
	'Richardson', 'Richmond', 'Riddle', 'Riggs', 'Riley', 'Rivas',
	'Rivera', 'Rivers', 'Roach', 'Roberts', 'Robertson', 'Robinson',
	'Rocha', 'Roddenberry', 'Rodriguez', 'Rogers', 'Rollins', 'Romero', 'Ronald', 'Rosa',
	'Rosales', 'Rosario', 'Rose', 'Ross', 'Rowe', 'Rowland', 'Ruiz',
	'Russel', 'Rutsky', 'Ryan', 'Sagan', 'Salas', 'Salazar', 'Salonen', 'Salt', 'Sampson', 'Sanchez',
	'Sanders', 'Sanford', 'Santana', 'Santiago', 'Sawyer', 'Schmidt',
	'Schneider', 'Schultz', 'Scott', 'Sears', 'Senese', 'Shao', 'Sharpe',
	'Shaw', 'Shen', 'Shepard', 'Sheppard', 'Shih', 'Simmons', 'Simpson',
	'Sims', 'Slater', 'Sloan', 'Smith', 'Snider', 'Snyder', 'Solis',
	'Solomon', 'Sosa', 'Soto', 'Spears', 'Spence', 'Spencer', 'Stanley',
	'Stanton', 'Stark', 'Stein', 'Stephens', 'Stevens', 'Stewart',
	'Stone', 'Stout', 'Su', 'Suarez', 'Sullivan', 'Sun', 'Sung', 'Sykes',
	'Tai', 'Talley', 'Tang', 'Tate', 'Taylor', 'Teerling', 'Teng',
	'Terrell', 'Thomas', 'Thompson', 'Thomson', 'Tillman', 'Ting',
	'Torres', 'Townsend', 'Travis', 'Tsaipeng', 'Tsao', 'Tseng', 'Tsou',
	'Tuan', 'Tucker', 'Tulloh', 'Turner', 'Tyler', 'Tyson', 'Valášek', 'Valdez',
	'Valencia', 'Valenzuela', 'Vang', 'Vasquez', 'Vazquez', 'Vega',
	'Velazquez', 'Vitorovi', 'Volk', 'Wagner', 'Walker', 'Wallace', 'Walls', 'Walter', 'Wan',
	'Wang', 'Wanstall', 'Ward', 'Warner', 'Warren', 'Washington', 'Watkins',
	'Watson', 'Watts', 'Weaver', 'Webb', 'Weeks', 'Wei', 'Weiss', 'Welch',
	'Wells', 'West', 'Westerhoff', 'Wheeler', 'White', 'Whitfield',
	'Wilder', 'William', 'Williams', 'Williamson', 'Willis', 'Wilson',
	'Wise', 'Witt', 'Wolfe', 'Wong', 'Wood', 'Woods', 'Woodward',
	'Wooten', 'Wright', 'Wu', 'Wynn', 'Yang', 'Yen', 'Yin', 'Young', 'Yu',
	'Yuan', 'Yung', 'Zamora', 'Zimmerman',
}
-- SAVEBUMP add:

NameGen.outdoorPlanetFormats = {
	"{name}",
	"{name}'s World",
	"{name}world",
	"{name} Colony",
	"{name}'s Hope",
	"{name}'s Dream",
	"New {name}",
}

NameGen.rockPlanetFormats = {
	"{name}'s Mine",
	"{name}'s Claim",
	"{name}'s Folly",
	"{name}'s Grave",
	"{name}'s Misery",
	"{name} Colony",
	"{name}'s Rock",
	"{name} Settlement",
}

NameGen.orbitalStarportFormats = {
	"{name}",
	"{name} Spaceport",
	"{name} High",
	"{name} Orbiter",
	"{name} Base",
	"{name} Station",
	"{name} Outpost",
	"{name} Citadel",
	"{name} Platform",
	"{name} Ring",
	"{name} Residence",
	"{name} Orbital",
	"{name} Habitat",
	"{name} Hub",
	"{name} Terminal",
	"{name} Trade Center",
	"{name} Commercial Center",
	"{name} Science Station",
	"{name} Observation Post",
	"{name} Facility",
	"{name} Industrial Center",
	"{name} Refinery",
	"{name} Dock",
	"{name} Depot",
	"{name} Anchorage",
}

NameGen.surfaceStarportFormats = {
	"{name}",
	"{name}",
	"{name} Starport",
	"{name} Spaceport",
	"{name} Town",
	"{name} City",
	"{name} Village",
	"Fort {name}",
	"Fortress {name}",
	"{name} Base",
	"{name} Station",
	"{name}ton",
	"{name}ville",
	"Port {name}",
	"{name} Port",
	"{name} Pad",
	"{name} Terminal",
	"{name} Oasis",
}

return NameGen
