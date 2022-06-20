package skald

//=----------------=//
// Author:  Szyfr   //
// Version: 1.00.0  //
//=----------------=//



//= Imports
import "../raylib"

//= Constants

//= Global Variables
@(private)
textboxCoreData: ^TextboxCoreData;


//= Structures
@(private)
TextboxCoreData :: struct {
	textspeed: u8,
	updateTic: u8,

	defaultTexture:  raylib.Texture,
	defaultCursor:   raylib.Texture,
	defaultFont:     raylib.Font,

	textboxes:       [dynamic]Textbox,
}
// TODO: color
@(private)
Textbox :: struct {
	position:           raylib.Vector2,
	size:               raylib.Vector2,
	offset:             raylib.Vector2,

	type:               TextboxType, // ???

	texture:            raylib.Texture,
	cursor:             raylib.Texture,
	nPatch:             raylib.N_Patch_Info,
	font:               raylib.Font,

	fontSize:           i32,

	currentText:        string,
	completeText:       [dynamic]string,

	options:            [dynamic]MenuOption,
	optionsPosition:    raylib.Vector2,
	optionsSize:        raylib.Vector2,

	clickable:          bool,
	displayCursor:      bool,
	positionCursor:     i32,
	dispChar, dispLine: u32,
}
MenuOption :: struct {
	text:   string,
	effect: proc(),
}


//= Enumerations
TextboxType :: enum { default, menu, }
ErrorCode :: enum { none, init_failed_check, already_init_skald, internal_error, def_texture_missing, def_cursor_missing, def_font_missing, closing_oob, };


//= Procedures