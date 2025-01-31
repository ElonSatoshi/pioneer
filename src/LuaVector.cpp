// Copyright © 2008-2019 Pioneer Developers. See AUTHORS.txt for details
// Licensed under the terms of the GPL v3. See licenses/GPL-3.txt

#include "LuaVector.h"
#include "LuaUtils.h"
#include "LuaVector2.h"
#include "libs.h"

static int l_vector_new(lua_State *L)
{
	LUA_DEBUG_START(L);
	double x = luaL_checknumber(L, 1);
	double y = luaL_checknumber(L, 2);
	double z = luaL_checknumber(L, 3);
	LuaVector::PushToLua(L, vector3d(x, y, z));
	LUA_DEBUG_END(L, 1);
	return 1;
}

vector3d construct_vec3(lua_State *L)
{
	const vector2d *vec2 = LuaVector2::GetFromLua(L, 2);
	double x, y, z;
	if (vec2 != nullptr) {
		x = vec2->x, y = vec2->y;
		z = luaL_optnumber(L, 3, 0.0);
	} else {
		x = luaL_checknumber(L, 2);
		if (lua_gettop(L) == 2)
			y = x, z = x;
		else {
			y = luaL_checknumber(L, 3);
			z = luaL_checknumber(L, 4);
		}
	}
	return vector3d(x, y, z);
}

/*
	Construct a new vector from:
	- one double
	- three doubles x, y, z
	- vector2 and an optional double
*/
static int l_vector_call(lua_State *L)
{
	LUA_DEBUG_START(L);
	LuaVector::PushToLua(L, construct_vec3(L));
	LUA_DEBUG_END(L, 1);
	return 1;
}

// set all three values of a Vector3 without allocating new memory.
static int l_vector_set(lua_State *L)
{
	LUA_DEBUG_START(L);
	*LuaVector::CheckFromLua(L, 1) = construct_vec3(L);
	lua_pushvalue(L, 1);
	LUA_DEBUG_END(L, 1);
	return 1;
}

static int l_vector_unit(lua_State *L)
{
	LUA_DEBUG_START(L);
	if (lua_isnumber(L, 1)) {
		double x = luaL_checknumber(L, 1);
		double y = luaL_checknumber(L, 2);
		double z = luaL_checknumber(L, 3);
		const vector3d v = vector3d(x, y, z);
		LuaVector::PushToLua(L, v.NormalizedSafe());
	} else {
		const vector3d *v = LuaVector::CheckFromLua(L, 1);
		LuaVector::PushToLua(L, v->NormalizedSafe());
	}
	LUA_DEBUG_END(L, 1);
	return 1;
}

static int l_vector_tostring(lua_State *L)
{
	const vector3d *v = LuaVector::CheckFromLua(L, 1);
	luaL_Buffer buf;
	luaL_buffinit(L, &buf);
	char *bufstr = luaL_prepbuffer(&buf);
	int len = snprintf(bufstr, LUAL_BUFFERSIZE, "vector(%g, %g, %g)", v->x, v->y, v->z);
	assert(len < LUAL_BUFFERSIZE); // XXX should handle this condition more gracefully
	luaL_addsize(&buf, len);
	luaL_pushresult(&buf);
	return 1;
}

static int l_vector_add(lua_State *L)
{
	const vector3d *a = LuaVector::CheckFromLua(L, 1);
	const vector3d *b = LuaVector::CheckFromLua(L, 2);
	LuaVector::PushToLua(L, *a + *b);
	return 1;
}

static int l_vector_sub(lua_State *L)
{
	const vector3d *a = LuaVector::CheckFromLua(L, 1);
	const vector3d *b = LuaVector::CheckFromLua(L, 2);
	LuaVector::PushToLua(L, *a - *b);
	return 1;
}

static int l_vector_mul(lua_State *L)
{
	if (lua_isnumber(L, 1)) {
		const double s = lua_tonumber(L, 1);
		const vector3d *v = LuaVector::CheckFromLua(L, 2);
		LuaVector::PushToLua(L, s * *v);
	} else if (lua_isnumber(L, 2)) {
		const vector3d *v = LuaVector::CheckFromLua(L, 1);
		const double s = lua_tonumber(L, 2);
		LuaVector::PushToLua(L, *v * s);
	} else {
		return luaL_error(L, "general vector product doesn't exist; please use dot() or cross()");
	}
	return 1;
}

static int l_vector_div(lua_State *L)
{
	if (lua_isnumber(L, 2)) {
		const vector3d *v = LuaVector::CheckFromLua(L, 1);
		const double s = lua_tonumber(L, 2);
		LuaVector::PushToLua(L, *v / s);
		return 1;
	} else if (lua_isnumber(L, 1)) {
		return luaL_error(L, "cannot divide a scalar by a vector");
	} else {
		return luaL_error(L, "Vector3 div not involving a vector (huh?)");
	}
}

static int l_vector_unm(lua_State *L)
{
	const vector3d *v = LuaVector::CheckFromLua(L, 1);
	LuaVector::PushToLua(L, -*v);
	return 1;
}

static int l_vector_new_index(lua_State *L)
{
	vector3d *v = LuaVector::CheckFromLua(L, 1);
	if (lua_type(L, 2) == LUA_TSTRING) {
		const char *attr = luaL_checkstring(L, 2);
		if (attr[0] == 'x') {
			v->x = luaL_checknumber(L, 3);
		} else if (attr[0] == 'y') {
			v->y = luaL_checknumber(L, 3);
		} else if (attr[0] == 'z') {
			v->z = luaL_checknumber(L, 3);
		} else {
			luaL_error(L, "Index '%s' is not available: use 'x', 'y' or 'z'", attr);
		}

	} else {
		luaL_error(L, "Expected Vector3, but type is '%s'", luaL_typename(L, 2));
	}
	LuaVector::PushToLua(L, *v);
	return 1;
}

static int l_vector_index(lua_State *L)
{
	const vector3d *v = LuaVector::CheckFromLua(L, 1);
	size_t len = 0;
	const char *attr = nullptr;
	if (lua_type(L, 2) == LUA_TSTRING) {
		attr = lua_tolstring(L, 2, &len);
		if (attr != nullptr && len == 1) {
			if (attr[0] == 'x') {
				lua_pushnumber(L, v->x);
				return 1;
			} else if (attr[0] == 'y') {
				lua_pushnumber(L, v->y);
				return 1;
			} else if (attr[0] == 'z') {
				lua_pushnumber(L, v->z);
				return 1;
			}
		};
	} else {
		luaL_error(L, "Expected Vector, but type is '%s'", luaL_typename(L, 2));
	}
	lua_getmetatable(L, 1);
	lua_pushvalue(L, 2);
	lua_rawget(L, -2);
	lua_remove(L, -2);
	return 1;
}

static int l_vector_normalised(lua_State *L)
{
	const vector3d *v = LuaVector::CheckFromLua(L, 1);
	LuaVector::PushToLua(L, v->NormalizedSafe());
	return 1;
}

static int l_vector_length_sqr(lua_State *L)
{
	const vector3d *v = LuaVector::CheckFromLua(L, 1);
	lua_pushnumber(L, v->LengthSqr());
	return 1;
}

static int l_vector_length(lua_State *L)
{
	const vector3d *v = LuaVector::CheckFromLua(L, 1);
	lua_pushnumber(L, v->Length());
	return 1;
}

static int l_vector_dot(lua_State *L)
{
	const vector3d *a = LuaVector::CheckFromLua(L, 1);
	const vector3d *b = LuaVector::CheckFromLua(L, 2);
	lua_pushnumber(L, a->Dot(*b));
	return 1;
}

static int l_vector_cross(lua_State *L)
{
	const vector3d *a = LuaVector::CheckFromLua(L, 1);
	const vector3d *b = LuaVector::CheckFromLua(L, 2);
	LuaVector::PushToLua(L, a->Cross(*b));
	return 1;
}

static luaL_Reg l_vector_lib[] = {
	{ "new", &l_vector_new },
	{ "unit", &l_vector_unit },
	{ "cross", &l_vector_cross },
	{ "dot", &l_vector_dot },
	{ "length", &l_vector_length },
	{ 0, 0 }
};

static luaL_Reg l_vector_meta[] = {
	{ "__tostring", &l_vector_tostring },
	{ "__add", &l_vector_add },
	{ "__sub", &l_vector_sub },
	{ "__mul", &l_vector_mul },
	{ "__div", &l_vector_div },
	{ "__unm", &l_vector_unm },
	{ "__index", &l_vector_index },
	{ "__newindex", &l_vector_new_index },
	{ "__call", &l_vector_set },
	{ "normalised", &l_vector_normalised },
	{ "normalized", &l_vector_normalised },
	{ "unit", &l_vector_unit },
	{ "lengthSqr", &l_vector_length_sqr },
	{ "length", &l_vector_length },
	{ "cross", &l_vector_cross },
	{ "dot", &l_vector_dot },
	{ 0, 0 }
};

const char LuaVector::LibName[] = "Vector3";
const char LuaVector::TypeName[] = "Vector3";

void LuaVector::Register(lua_State *L)
{
	LUA_DEBUG_START(L);

	luaL_newlib(L, l_vector_lib);

	lua_newtable(L);
	lua_pushcfunction(L, &l_vector_call);
	lua_setfield(L, -2, "__call");
	lua_setmetatable(L, -2);

	lua_setglobal(L, LuaVector::LibName);

	luaL_newmetatable(L, LuaVector::TypeName);
	luaL_setfuncs(L, l_vector_meta, 0);
	// hide the metatable to thwart crazy exploits
	lua_pushboolean(L, 0);
	lua_setfield(L, -2, "__metatable");
	lua_pop(L, 1);

	LUA_DEBUG_END(L, 0);
}

vector3d *LuaVector::PushNewToLua(lua_State *L)
{
	vector3d *ptr = static_cast<vector3d *>(lua_newuserdata(L, sizeof(vector3d)));
	luaL_setmetatable(L, LuaVector::TypeName);
	return ptr;
}

const vector3d *LuaVector::GetFromLua(lua_State *L, int idx)
{
	return static_cast<vector3d *>(luaL_testudata(L, idx, LuaVector::TypeName));
}

vector3d *LuaVector::CheckFromLua(lua_State *L, int idx)
{
	return static_cast<vector3d *>(luaL_checkudata(L, idx, LuaVector::TypeName));
}
