open Graphics

val i = IntInf.toInt

val d = 350
val buf1 = 25
val buf = 200

val file =
    case CommandLine.arguments () of
        f::t => f
      | _ => (print "Usage: vis <problem file>\n";
              OS.Process.exit OS.Process.failure)

val _ = openwindow NONE (i (d * 2 + buf * 2 + buf1 * 2), i (d + buf + buf1))

val _ = setforeground (MLX.fromints 0 0 0)
val _ = MLX.usleep 10000

fun int_of_rat (a, b) = i (Int.div (a * d, b))

fun draw_edge (offx, offy) ((x1, y1), (x2, y2)) =
    let val (x1, y1) = (int_of_rat x1, int_of_rat y1)
        val (x2, y2) = (int_of_rat x2, int_of_rat y2)
(*        val _ = print ((Int32.toString x1) ^ ", " ^ (Int32.toString y1) ^ "-" ^
                       (Int32.toString x2) ^ ", " ^ (Int32.toString y2) ^ "\n") *)
    in
        drawline (Int32.+ (offx, x1))
                 (Int32.+ (offy, y1))
                 (Int32.+ (offx, x2))
                 (Int32.+ (offy, y2))
    end

fun draw_skel (off: Int32.int * Int32.int) (s: skelly) =
    List.app (draw_edge off) s

fun draw_poly off ps =
    let fun edges ps =
            (* Input: a list of points, clockwise or counterclockwise,
               where the first and last points are the same. *)
            case ps of
                p1::p2::[] => [(p1, p2)]
              | p1::p2::t =>
                (p1, p2)::(edges (p2::t))
    in
        List.app (draw_edge off) (edges (ps @ [List.hd ps]))
    end

fun draw_sil (off: Int32.int * Int32.int) (s: silly) =
    List.app (draw_poly off) s



fun center_prob (sil, skel) =
    let fun mins pts =
            case pts of
                (x,y)::[] => (x, y)
              | (x,y)::t =>
                let val (minx, miny) = mins t
                in
                    (Rat.min (x, minx), Rat.min (y, miny))
                end
        fun edge_pts (p1, p2) = [p1, p2]
        fun sil_pts sil = List.concat sil
        fun skel_pts skel = List.concat (List.map edge_pts skel)
        fun translate_pt (tx, ty) (x, y) =
            (Rat.add (tx, x), Rat.add (ty, y))
        fun translate_edge (tx, ty) ((x1, y1), (x2, y2)) =
            (translate_pt (tx, ty) (x1, y1),
             translate_pt (tx, ty) (x2, y2))
        fun translate_poly (tx, ty) pts =
            List.map (translate_pt (tx, ty)) pts
        fun translate_sil (tx, ty) sil =
            List.map (translate_poly (tx, ty)) sil
        fun translate_skel (tx, ty) skel =
            List.map (translate_edge (tx, ty)) skel
        fun center_sil sil =
            let val pts = sil_pts sil
                val (minx, miny) = mins pts
            in
                translate_sil (Rat.neg minx, Rat.neg miny) sil
            end
        fun center_skel skel =
            let val pts = skel_pts skel
                val (minx, miny) = mins pts
            in
                translate_skel (Rat.neg minx, Rat.neg miny) skel
            end
    in
        (center_sil sil, center_skel skel)
    end

fun draw_prob (p: problem) =
    let val (sil, skel) = center_prob p
    in
        draw_sil (i buf1, i buf1) sil;
        draw_skel (i (d + buf + buf1), i buf1) skel;
        flush ()
    end

val _ = draw_prob (load file)

fun loop () = (MLX.usleep 1000; loop ())

val _ = loop ()
