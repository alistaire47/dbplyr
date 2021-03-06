# R prefers to specify start / stop or start / end
# databases usually specify start / length
# https://www.postgresql.org/docs/current/functions-string.html
#' @export
#' @rdname sql_variant
sql_substr <- function(f = "SUBSTR") {
  function(x, start, stop) {
    start <- as.integer(start)
    length <- pmax(as.integer(stop) - start + 1L, 0L)

    sql_call2(f, x, start, length)
  }
}

# str_sub(x, start, end) - start and end can be negative
# SUBSTR(string, start, length) - start can be negative

#' @export
#' @rdname sql_variant
sql_str_sub <- function(subset_f = "SUBSTR", length_f = "LENGTH") {
  function(string, start = 1L, end = -1L) {
    stopifnot(length(start) == 1L, length(end) == 1L)
    start <- as.integer(start)
    end <- as.integer(end)

    if (end == -1L) {
      sql_call2(subset_f, string, start)
    } else if (end <= 0) {
      if (start < 0) {
        length <- pmax(- start + end + 1L, 0L)
      } else {
        length <- sql_expr(!!sql_call2(length_f, string) - !!(abs(end) - 1L))
      }
      sql_call2(subset_f, string, start, length)
    } else if (end > 0) {
      length <- pmax(end - start + 1L, 0L)
      sql_call2(subset_f, string, start, length)
    }
  }
}

sql_str_trim <- function(string, side = c("both", "left", "right")) {
  side <- match.arg(side)
  switch(side,
    left = sql_expr(LTRIM(!!string)),
    right = sql_expr(RTRIM(!!string)),
    both = sql_expr(LTRIM(RTRIM(!!string))),
  )
}
