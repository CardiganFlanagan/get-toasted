class_name PixelBurst
extends GPUParticles2D


func explode(sprite: AnimatedSprite2D) -> void:
	var frame: AtlasTexture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var params: ShaderMaterial = process_material.duplicate()
	process_material = params
	params.set_shader_parameter("sprite", frame.atlas)
	params.set_shader_parameter("region", frame.region)
	params.set_shader_parameter("offset", sprite.offset)
	params.set_shader_parameter("flip_h", sprite.flip_h)
	amount = int(frame.region.size.x * frame.region.size.y)
	scale = sprite.global_scale
