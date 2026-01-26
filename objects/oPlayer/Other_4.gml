//Daca exista salvari anterioare le stergem
if(file_exists(SAVEFILE)) file_delete(SAVEFILE);

//Cream noua salvare
file=file_text_open_write(SAVEFILE);
file_text_write_real(file, room);
file_text_close(file);