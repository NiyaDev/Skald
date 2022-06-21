package main



import "core:fmt"
import "core:strings"

import "raylib"
import "skald"


test_proc1 :: proc() { fmt.printf("fuck1\n"); }
test_proc2 :: proc() { fmt.printf("fuck2\n"); }

//= Main
main :: proc() {

	{ // Initialization
		raylib.init_window(1280, 720, "Skald Testing");
		raylib.set_target_fps(60);
	}

	res := skald.init_skald();
	if skald.output_error(res) do return;

	img: raylib.Image   = raylib.load_image("data/skald/textbox.png");
	tex: raylib.Texture = raylib.load_texture_from_image(img);
	raylib.unload_image(img);


	text: [dynamic]string;
	append(&text, "Fuck me?","No fuck me!");
	menuOptions: [dynamic]skald.MenuOption;
	append(&menuOptions, skald.MenuOption{text="Fight",effect=test_proc1},skald.MenuOption{text="Items",effect=test_proc2}, skald.MenuOption{text="Run",effect=skald.default_option});
	res = skald.create_textbox(
		textboxRect=raylib.Rectangle{100,100,600,200},
		texture=tex,
		textDynamic=text, fontColor=raylib.RED,
		options=menuOptions);
	if skald.output_error(res) do return;


	for !raylib.window_should_close() {
		// Updating
		{
			res = skald.update_textboxes();
			if skald.output_error(res) do return;
		}

		// Drawing
		{
			raylib.begin_drawing();
				raylib.clear_background(raylib.RAYWHITE);
					
					res = skald.draw_textboxes();
					if skald.output_error(res) do return;

					raylib.draw_fps((8 * 3), (8 * 5));
			raylib.end_drawing();
		}
	}

	res = skald.free_skald();
	if skald.output_error(res) do return;

	raylib.close_window();
}
