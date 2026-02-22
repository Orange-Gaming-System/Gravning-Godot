class_name OGSLib extends Object

## Library used in Orange Gaming System games with lots of useful functions.
##
## Contains a lot of functions I use or intend to use regularly. Place as a script on a Global to access anywhere.

## Converts [code]array[/code] to a vector. If [code]array[/code]'s size is 2, returns a Vector2, if [code]array[/code]'s size is 3, returns a Vector3. If [code]array[/code] has any other size, returns [code]ERR_PARAMETER_RANGE_ERROR[/code].[br][br]If [code]is_int[/code] is [code]true[/code], the function will output [Vector2i] or [Vector3i] instead.[br][br]See [method vector_to_array] for the opposite conversion.
static func array_to_vector(array: Array, is_int: bool = false):
    if !is_int:
        if array.size() == 2:
            return Vector2(array[0], array[1])
        else: if array.size() == 3:
            return Vector3(array[0], array[1], array[2])
        else:
            return ERR_PARAMETER_RANGE_ERROR
    else:
        if array.size() == 2:
            return Vector2i(array[0], array[1])
        else: if array.size() == 3:
            return Vector3i(array[0], array[1], array[2])
        else:
            return ERR_PARAMETER_RANGE_ERROR

## Converts [code]vector[/code] to an array. If [code]vector[/code] is not a [Vector2], [Vector2i], [Vector3], or [Vector3i], the function will return [code]ERR_INVALID_PARAMETER[/code].[br][br]See [method array_to_vector] for the opposite conversion.
static func vector_to_array(vector: Variant):
    if vector is Vector2 or vector is Vector2i:
        return [vector.x, vector.y]
    else: if vector is Vector3 or vector is Vector3i:
        return [vector.x, vector.y, vector.z]
    else:
        return ERR_INVALID_PARAMETER

## Converts [code]dictionary[/code] to a vector. [code]dictionary[/code] should have an [code]"x"[/code] and [code]"y"[/code] key, and a [code]"z"[/code] key if converting to a [Vector3]. In absence of a [code]"z"[/code] key, returns a [Vector2]. If there is no [code]"x"[/code] key or no [code]"y"[/code] key, the function will return [code]ERR_INVALID_PARAMETER[/code].[br][br]If [code]is_int[/code] is [code]true[/code], the function will output [Vector2i] or [Vector3i] instead.[br][br]See [method vector_to_dictionary] for the opposite conversion.
static func dictionary_to_vector(dictionary: Dictionary, is_int: bool = false):
    if !is_int:
        if dictionary.has("x") and dictionary.has("y"):
            if dictionary.has("z"):
                return Vector3(dictionary.x, dictionary.y, dictionary.z)
            else:
                return Vector2(dictionary.x, dictionary.y)
        else:
            return ERR_INVALID_PARAMETER
    else:
        if dictionary.has("x") and dictionary.has("y"):
            if dictionary.has("z"):
                return Vector3i(dictionary.x, dictionary.y, dictionary.z)
            else:
                return Vector2i(dictionary.x, dictionary.y)
        else:
            return ERR_INVALID_PARAMETER

## Converts [code]vector[/code] into a dictionary. If [code]vector[/code] is not a [Vector2], [Vector2i], [Vector3], or [Vector3i], the function will return [code]ERR_INVALID_PARAMETER[/code].[br][br]See [method vector_to_dictionary] for the opposite conversion.
static func vector_to_dictionary(vector: Variant):
    if vector is Vector2 or vector is Vector2i:
        return {"x": vector.x, "y": vector.y}
    else: if vector is Vector3 or vector is Vector3i:
        return {"x": vector.x, "y": vector.y, "z": vector.z}
    else:
        return ERR_INVALID_PARAMETER

## Encodes the direction names used by [method get_dir_name]. Contains all four cardinal directions, as well as zero.
const dir_name: Dictionary[Vector2, String] = {Vector2.LEFT: "left", Vector2.RIGHT: "right", Vector2.DOWN: "down", Vector2.UP: "up", Vector2.ZERO: "zero"}

## Gets the name of a direction as defined in [constant dir_name] for any arbitrary vector, given as [param dir]. It gives the direction of the largest axis. If both axis are the same, it will give the direction for y unless [param prefer_x] is true.
static func get_dir_name(dir: Vector2, prefer_x: bool = false):
    if dir_name.has(dir):
        return dir_name[dir]
    if dir.x > dir.y:
        return dir_name[Vector2(sign(dir.x), 0)]
    if dir.x < dir.y:
        return dir_name[Vector2(0, sign(dir.y))]
    # If x and y are the same, prefer y unless prefer_x.
    if prefer_x:
        return dir_name[Vector2(sign(dir.x), 0)]
    else:
        return dir_name[Vector2(0, sign(dir.y))]
