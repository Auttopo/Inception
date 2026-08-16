<?php
function wp_cache_init() {
        $g = $GLOBALS['wp_object_cache'] = new stdClass();
        $g->r = new Redis();
        @$g->r->connect(defined('WP_REDIS_HOST') ? WP_REDIS_HOST : 'redis', 6379);
}
function wp_cache_add($k, $d, $g = 'default', $e = 0) { return wp_cache_set($k, $d, $g, $e); }
function wp_cache_set($k, $d, $g = 'default', $e = 0) {
        $r = $GLOBALS['wp_object_cache']->r;
        return $r ? ($e > 0 ? $r->setex("wp:$g:$k", (int)$e, serialize($d)) : $r->set("wp:$g:$k", serialize($d))) : false;
}
function wp_cache_get($k, $g = 'default', $f = false, &$found = null) {
        $r = $GLOBALS['wp_object_cache']->r;
        if (!$r || ($v = $r->get("wp:$g:$k")) === false) { $found = false; return false; }
        $found = true; return unserialize($v);
}
function wp_cache_delete($k, $g = 'default') { return ($r = $GLOBALS['wp_object_cache']->r) ? $r->del("wp:$g:$k") > 0 : false; }
function wp_cache_flush() { return ($r = $GLOBALS['wp_object_cache']->r) ? $r->flushDB() : false; }
function wp_cache_close() { return true; }
