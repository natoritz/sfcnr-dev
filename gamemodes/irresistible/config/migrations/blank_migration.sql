
	CREATE TABLE IF NOT EXISTS GANG_FACILITIES (
		ID int(11) AUTO_INCREMENT primary key,
		GANG_ID int(11),
		ENTER_X float,
		ENTER_Y float,
		ENTER_Z float,
		ZONE_MIN_X float,
		ZONE_MIN_Y float,
		ZONE_MAX_X float,
		ZONE_MAX_Y float
	);

	TRUNCATE TABLE GANG_FACILITIES;
	INSERT INTO GANG_FACILITIES (GANG_ID, ENTER_X, ENTER_Y, ENTER_Z, ZONE_MIN_X, ZONE_MIN_Y, ZONE_MAX_X, ZONE_MAX_Y) VALUES
	(10619, -2056.4568,453.9176,35.1719, -2068, 446.5, -2009, 501.5),
	(10619, -1697.5094,883.6597,24.8982, -1723, 857.5, -1642, 911.5),
	(10619, -1606.2400,773.2818,7.1875, -1642, 755.5, -1563, 829.5),
	(10619, -1715.8917,1018.1326,17.9178,-1803, 964.5, -1722, 1037.5),
	(10619, -2754.3115, 90.5159, 7.0313, -2763, 78.5, -2710, 154.5),
	(10619, -2588.1001,59.9101,4.3544,-2613, 49.5, -2532, 79.5);

	CREATE TABLE IF NOT EXISTS GANG_FACILITIES_VEHICLES (
		`ID` int(11) primary key auto_increment,
		`GANG_ID` int(11),
		`MODEL` int(3),
		`PRICE` int(11),
		`COLOR1` int(3),
		`COLOR2` int(3),
		`PAINTJOB` tinyjob(1)
		`MODS` varchar(96)
	);