package skald2



//= Imports
import "../raylib"


//= Constants

//= Global Variables
@(private)
textboxCore: ^TextboxCore;


//= Structures
@(private)
TextboxCore :: struct {
	defaultTextures:  Textures,
	defaultTextSpeed: u8,
	defaultTextSize:  f32,

	textboxes: [dynamic]Textbox,
}


//= Enumerations

//= Procedures
init_skald :: proc(
		cursor:    raylib.Texture={},
		texture:   raylib.Texture={},
		nPatch:    raylib.N_Patch_Info={},
		font:      raylib.Font={},
		textSpeed: u8=2,
		textSize:  f32=16) {

	textboxCore = new(TextboxCore);

	// Generate placeholder default
	img: raylib.Image = raylib.gen_image_gradient_v(48, 48, raylib.BLACK, raylib.WHITE);

	// Cursor
	if cursor == {} {
		textboxCore.defaultTextures.cursor = raylib.load_texture_from_image(img);
		raylib.unload_image(img);
	} else do textboxCore.defaultTextures.cursor = texture;

	// Textbox texture
	if texture == {} {
		textboxCore.defaultTextures.texture = raylib.load_texture_from_image(img);
		raylib.unload_image(img);
	} else do textboxCore.defaultTextures.texture = texture;

	// N-Patch
	if nPatch == {} {
		textboxCore.defaultTextures.nPatch = {};
		textboxCore.defaultTextures.nPatch.source = raylib.Rectangle{0, 0, f32(textboxCore.defaultTextures.texture.width), f32(textboxCore.defaultTextures.texture.height)};
		textboxCore.defaultTextures.nPatch.left   = textboxCore.defaultTextures.texture.width  / 3;
		textboxCore.defaultTextures.nPatch.top    = textboxCore.defaultTextures.texture.height / 3;
		textboxCore.defaultTextures.nPatch.right  = textboxCore.defaultTextures.texture.width  / 3;
		textboxCore.defaultTextures.nPatch.bottom = textboxCore.defaultTextures.texture.height / 3;
		textboxCore.defaultTextures.nPatch.layout = i32(raylib.N_Patch_Layout.NPATCH_NINE_PATCH);
	}

	// Font
	if font == {} {
		textboxCore.defaultTextures.font = raylib.get_font_default();
	} else do textboxCore.defaultTextures.font = font;

	// Textspeed / Textsize
	textboxCore.defaultTextSpeed = textSpeed;
	textboxCore.defaultTextSize  = textSize;

	// Textbox array
	textboxCore.textboxes = make([dynamic]Textbox);
}
free_skald :: proc() {
	raylib.unload_texture(textboxCore.defaultTextures.cursor);
	raylib.unload_texture(textboxCore.defaultTextures.texture);
	raylib.unload_font(textboxCore.defaultTextures.font);
	free(textboxCore);
}