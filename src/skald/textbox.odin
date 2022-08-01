package skald



//= Imports
import "../raylib"


//= Constants

//= Global Variables

//= Structures

//= Enumerations

//= Procedures

// Create textbox
create_textbox :: proc(
		textboxRect:     raylib.Rectangle    = { 0, 0, 200, 100},
		offset:          raylib.Vector2      = { 16, 16},
		
		texture:         raylib.Texture      = {},
		cursor:          raylib.Texture      = {},
		npatch:          raylib.N_Patch_Info = {},

		font:            raylib.Font         = {},
		fontSize:        f32                 = 20,
		fontColor:       raylib.Color        = raylib.BLACK,
		
		textDynamic:     [dynamic]string     = nil,
		textSingle:      string              = "",
		options:         [dynamic]MenuOption = nil,
		optionsRect:     raylib.Rectangle    = {}) -> ErrorCode {
	res := init_check();
	if output_error(res) do return res;

	textbox: Textbox    = {};
	textbox.textboxRect = textboxRect;
	textbox.offset      = offset;
	textbox.fontSize    = fontSize;
	textbox.fontColor   = fontColor;
	
	// Checking for empty texture input
	if texture == {} do textbox.texture = textboxCoreData.defaultTexture;
	else             do textbox.texture = texture;

	// Checking for empty cursor input
	if cursor == {}  do textbox.cursor = textboxCoreData.defaultCursor;
	else             do textbox.cursor = cursor;

	// Checking for empty font input
	if font == {}    do textbox.font = textboxCoreData.defaultFont;
	else             do textbox.font = font;

	// Calculating NPatch
	if npatch == {} {
		textbox.nPatch = {};
		textbox.nPatch.source = raylib.Rectangle{0, 0, f32(textbox.texture.width), f32(textbox.texture.height)};
		textbox.nPatch.left   = textbox.texture.width  / 3;
		textbox.nPatch.top    = textbox.texture.height / 3;
		textbox.nPatch.right  = textbox.texture.width  / 3;
		textbox.nPatch.bottom = textbox.texture.height / 3;
		textbox.nPatch.layout = i32(raylib.N_Patch_Layout.NPATCH_NINE_PATCH);
	} else do textbox.nPatch = npatch;

	// Text
	if textDynamic == nil {
		textbox.completeText = make([dynamic]string);
		if textSingle != "" do append(&textbox.completeText,textSingle);
		else                do append(&textbox.completeText,"ERROR: NO TEXT INPUT");
	} else do textbox.completeText = textDynamic;

	// Options
	if options == nil {
		textbox.options = make([dynamic]MenuOption);
		
		defaultOption: MenuOption = {"", default_option};
		append(&textbox.options,defaultOption);
	} else do textbox.options = options;

	if optionsRect == {} {
		textbox.optionsRect.width  = 200;
		textbox.optionsRect.height = f32((len(textbox.options) - 1) * int(textbox.fontSize)) + 64;
		textbox.optionsRect.x = textbox.textboxRect.width - (textbox.textboxRect.width / 3) + textbox.textboxRect.x;
		textbox.optionsRect.y = textbox.textboxRect.y;
	} else do textbox.optionsRect = optionsRect;


	append(&textboxCoreData.textboxes, textbox);


	return .none;
}

// Close textbox
close_textbox :: proc(index: int) -> ErrorCode {
	if len(textboxCoreData.textboxes) == 0    do return .closing_oob;
	if index > len(textboxCoreData.textboxes) do return .closing_oob;

	listCopy: [dynamic]Textbox = make([dynamic]Textbox);

	for i:=0; i < len(textboxCoreData.textboxes); i+=1 {
		if i == index do continue;
		append(&listCopy, textboxCoreData.textboxes[i]);
	}

	delete(textboxCoreData.textboxes);
	textboxCoreData.textboxes = listCopy;

	return .none;
}