// Distruge jumătățile când oIvy dispare
if (instance_exists(ivy_back)) instance_destroy(ivy_back);
if (instance_exists(ivy_front)) instance_destroy(ivy_front);

// Lasă particulele să termine înainte de a distruge sistemul
part_type_destroy(p_dirt);
part_system_destroy(p_sys);
