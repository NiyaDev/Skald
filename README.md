# Skald
---
#### Language: Odin
#### Version 1.00.0
---

Skald is a Textbox system for game development that is made to be simple to use.


# Documentation
---
### General Procedures:
>__`init_skald() -> ErrorCode`__
>
>initializes core structure and sets default variables.
>
>__Input:__
> `speed: u8 = 2` Text speed.
>
> `texture, cursor: Raylib.Texture = {}` Default textures. If empty it will create small placeholders.
>
> `font: Raylib.Font = {}` Default font. If empty, it will grab Raylib's current font.

>__`free_skald() -> ErrorCode`__
>
>Frees all allocated data.

>__`create_textbox() -> ErrorCode`__
>
>Creates a textbox.
>
>__Input:__
>`position, size, offset: Raylib.Vector2` Transform of the textbox.
>
>`texture, cursor: Raylib.Texture = {}` Sets textures. If empty, will use default.
>
>`npatch: Raylib.N_Patch_Info = {}` The NPatch settings for the texture.
>
>`font: Raylib.Font = {}` Sets font. If empty, will use default.
>
>`fontsize: i32 = 20` Font size.
>
>`textDynamic: [dynamic]string = nil` A dynamic list of strings. Each string will be displayed individually per box, and box will keep going until the end.
>
>`textSingle: string = ""` Used if only a single line needed. If both are empty it will fill this with a placegolder.
>
>`options: [dynamic]MenuOption = nil` Used for player choice.

>__`update_textboxes() -> ErrorCode`__
>
>Updates the logic of the textboxes.

>__`draw_textboxes() -> ErrorCode`__
>
>Draws the textboxes to screen.

>__`close_textbox() -> ErrorCode`__
>
>Forcibly closes textbox.
>
>__Input:__
>`index: int` The index of the textbox to close.

>__`output_error() -> ErrorCode`__
>
>Prints to console the input error code
>
>__Input:__
>`error: ErrorCode` Code to print.


## TODO:
[ ] Make it so that you can make single choice textboxes