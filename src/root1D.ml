(* File: RootFinding.ml

   Copyright (C) 2007

     Christophe Troestler
     email: Christophe.Troestler@umh.ac.be
     WWW: http://math.umh.ac.be/an/software/

   This library is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 2.1 or
   later as published by the Free Software Foundation, with the special
   exception on linking described in the file LICENSE.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
   LICENSE for more details. *)

open Printf

let eps = sqrt epsilon_float

exception Root of float
  (* Internal exception used when the exact root is found *)


(* Assume fa = f(a) < 0 < fb = f(b).  A recursive function is more
   elegant but we do it imperatively to allow the compiler to unbox
   the floats. *)
let do_bisection good_enough f a b fa fb =
  let a = ref a and b = ref b
  and fa = ref fa and fb = ref fb in
  try
    while not(good_enough !a !b !fa !fb) do
      let m = 0.5 *. (!a +. !b) in
      let fm = f m in
      if fm = 0. then raise(Root m)
      else if fm < 0. then (a := m; fa := fm)
      else (* fm > 0. *) (b := m; fb := fm)
    done;
    0.5 *. (!a +. !b)
  with Root r -> r

let bisection_good a b _ _ =
  abs_float(a -. b) < eps *. (abs_float a +. abs_float b)

let bisection ?(good_enough=bisection_good) f a b =
  let fa = f a
  and fb = f b in
  if fa = 0. then a
  else if fa < 0. then
    if fb = 0. then b
    else if fb < 0. then
      invalid_arg "Root1D.bisection: f(a) and f(b) are both < 0."
    else (* fb > 0. *)
      do_bisection good_enough f a b fa fb
  else (* fa > 0. *)
    if fb = 0. then b
    else if fb > 0. then
      invalid_arg "Root1D.bisection: f(a) and f(b) are both > 0."
    else (* fb < 0. *)
      do_bisection good_enough f b a fb fa

let newton_good x xpre fx = abs_float fx < eps

let newton ?(good_enough=newton_good) f_f' x0 =
  let x = ref x0
  and xpre = ref nan (* FIXME: confusing for good_enough *)
  and fx, f'x = f_f' x0 in
  let fx = ref fx
  and f'x = ref f'x in
  while not(good_enough !x !xpre !fx) do
    if !f'x = 0. then failwith(sprintf "Root1D.newton: f'(%g) = 0" !x);
    x := !x -. !fx /. !f'x;
    let fx_next, f'x_next = f_f' !x in
    fx := fx_next;
    f'x := f'x_next;
  done;
  !x


let secant ?(good_enough) f a b =
  a

let false_position ?(good_enough) f a b =
  a

let muller f a b = a



(* Based on http://www.netlib.org/c/brent.shar zeroin  and
   http://www.netlib.org/go/zeroin.f

   Algorithm

   G.Forsythe, M.Malcolm, C.Moler, Computer methods for mathematical
   computations. M., Mir, 1980, p.180 of the Russian edition

   The function makes use of the bissection procedure combined with
   the linear or quadric inverse interpolation.
   At every step program operates on three abscissae - a, b, and c.
   b - the last and the best approximation to the root
   a - the last but one approximation
   c - the last but one or even earlier approximation than a that
       1) |f(b)| <= |f(c)|
       2) f(b) and f(c) have opposite signs, i.e. b and c confine
     	  the root
   At every step Zeroin selects one of the two new approximations, the
   former being obtained by the bissection procedure and the latter
   resulting in the interpolation (if a,b, and c are all different
   the quadric interpolation is utilized, otherwise the linear one).
   If the latter (i.e. obtained by the interpolation) point is
   reasonable (i.e. lies within the current interval [b,c] not being
   too close to the boundaries) it is accepted. The bissection result
   is used in the other case. Therefore, the range of uncertainty is
   ensured to be reduced at least by the factor 1.6 *)
let brent ?(tol=eps) f a b =
  let a = ref a
  and b = ref b
  and c = ref a in
  let fa = ref(f !a)
  and fb = ref(f !b) in
  let fc = ref(!fa) in
  if (!fa < 0. && !fb < 0.) || (!fa > 0. && !fb > 0.) then
    invalid_arg "Root1D.brent: f(a) and f(b) must have opposite signs";
  try
    while true do
      let prev_step = !b -. !a in
      (* Swap b and c for b to be the best approximation *)
      if abs_float !fc < abs_float !fb then (
        a := !b;   b := !c;   c := !a;
        fa := !fb; fb := !fc; fc := !fa;
      );
      let tol_act = 2. *. epsilon_float *. abs_float(!b) +. 0.5 *. tol in
      let bisec_step = 0.5 *. (!c -. !b) in
      if abs_float bisec_step <= tol_act || !fb = 0. then
        raise(Root !b);
      let new_step =
        if abs_float prev_step >= tol_act
           && abs_float !fa > abs_float !fb then
          (* prev_step was large enough and was in true direction,
             Interpolatiom may be tried *)
          let c_b = !c -. !b in
          let p, q =
            if !a = !c then
              (* linear interpolation *)
              let s = !fb /. !fa in (c_b *. s, 1. -. s)
            else
              (* Quadric inverse interpolation *)
              let t = !fa /. !fc and r = !fb /. !fc and s = !fb /. !fa in
              (s *. (c_b *. t *. (t -. r) -. (!b -. !a) *. (r -. 1.)),
               (t -. 1.) *. (r -. 1.) *. (s -. 1.)) in
          let p, q = if p > 0. then p, -. q else -. p, q in
          (* If b+p/q falls in [b,c] and isn't too large, it is accepted *)
          if p < 0.75 *. c_b *. q -. 0.5 *. abs_float(tol_act *. q)
             && p < abs_float(0.5 *. prev_step *. q) then p /. q
          else bisec_step
        else bisec_step in
      (* Adjust the step to be not less than tolerance *)
      let new_step =
        if new_step > 0. then
          if new_step < tol_act then tol_act else new_step
        else
          if -. new_step < tol_act then -. tol_act else new_step in
      a := !b;  fa := !fb; (* Save the previous approx. *)
      b := !b +. new_step;
      fb := f !b;
      (* Adjust c for it to have a sign opposite to that of b *)
      if (!fb > 0. && !fc > 0.) || (!fb < 0. && !fc < 0.) then (
        c := !a;  fc := !fa
      )
    done;
    assert false
  with Root r -> r
