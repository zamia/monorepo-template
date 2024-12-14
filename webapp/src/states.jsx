import { useAtom } from "jotai";
import { atomWithStorage } from "jotai/utils";

export const loginAtom = atomWithStorage("is_login", false, undefined, {getOnInit: true});
export const tokenAtom = atomWithStorage("token", "", undefined, {getOnInit: true});

