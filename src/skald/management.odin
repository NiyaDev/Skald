package skald



//= Imports
import "../raylib"

//= Constants

//= Global Variables

//= Structures

//= Enumerations

//= Procedures

// Initialization
init_skald :: proc(
		speed:   u8             = 2,
		texture: raylib.Texture = {},
		cursor:  raylib.Texture = {},
		font:    raylib.Font    = {}) -> ErrorCode {
	
	if textboxCoreData != nil do return .already_init_skald;

	textboxCoreData = new(TextboxCoreData);
	textboxCoreData.textspeed = speed;
	textboxCoreData.updateTick = 0;

	// Checking for empty texture input
	if texture == {} {
		img: raylib.Image = raylib.gen_image_gradient_v(48, 48, raylib.BLACK, raylib.WHITE);
		textboxCoreData.defaultTexture = raylib.load_texture_from_image(img);
		raylib.unload_image(img);
		
		if textboxCoreData.defaultTexture == {} do return .def_texture_missing;
	} else do textboxCoreData.defaultTexture = texture;

	// Checking for empty Cursor input
	if cursor == {} {
		img: raylib.Image = raylib.gen_image_color(16, 16, raylib.BLACK);
		textboxCoreData.defaultCursor = raylib.load_texture_from_image(img);
		raylib.unload_image(img);
		
		if textboxCoreData.defaultCursor == {} do return .def_cursor_missing;
	} else do textboxCoreData.defaultCursor = cursor;

	// Checking for empty Font input
	if font == {} {
		textboxCoreData.defaultFont = raylib.get_font_default();
		
		if textboxCoreData.defaultFont == {} do return .def_font_missing;
	} else do textboxCoreData.defaultFont = font;

	textboxCoreData.textboxes = make([dynamic]Textbox);

	return .none;
}

// Freeing
free_skald :: proc() -> ErrorCode {
	raylib.unload_texture(textboxCoreData.defaultTexture);
	raylib.unload_texture(textboxCoreData.defaultCursor);
	raylib.unload_font(textboxCoreData.defaultFont);

	delete(textboxCoreData.textboxes);
	free(textboxCoreData);

	return .none;
}