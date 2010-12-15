#define DDEBUG 1
#include "ddebug.h"

#include "ngx_http_redis2_reply.h"
#include "ngx_http_redis2_util.h"


%% machine status_code_reply;
%% write data;

ngx_int_t
ngx_http_redis2_process_status_code_reply(ngx_http_redis2_ctx_t *ctx,
        ssize_t bytes)
{
    ngx_buf_t                *b;
    ngx_http_upstream_t      *u;
    ngx_str_t                 buf;
    ngx_int_t                 rc;
    ngx_flag_t                done = 0;

    int                       cs;
    u_char                   *p;
    u_char                   *pe;

    u = ctx->request->upstream;
    b = &u->buffer;

    if (ctx->state == NGX_ERROR) {
        dd("init the state machine");

        %% machine status_code_reply;
        %% write init;

        ctx->state = cs;

    } else {
        cs = ctx->state;
        dd("resumed the old state %d", cs);
    }

    p  = b->last;
    pe = b->last + bytes;

    %% machine status_code_reply;
    %% include "status_code_reply.rl";
    %% write exec;

    dd("state after exec: %d, done: %d", cs, (int) done);

    ctx->state = cs;

    if (cs == status_code_reply_error) {

        buf.data = b->last;
        buf.len = bytes;

        ngx_log_error(NGX_LOG_ERR, ctx->request->connection->log, 0,
            "Redis server returns invalid response at %z near "
            "\"%V\"",
            (ssize_t) (b->last - b->pos),
            &buf);

        return NGX_ERROR;
    }

    rc = ngx_http_redis2_output_buf(ctx, b->last, p - b->last);
    if (rc != NGX_OK) {
        return NGX_ERROR;
    }

    b->last = p;

    if (done) {
        u->length = 0;
    }

    return NGX_OK;
}


ngx_int_t
ngx_http_redis2_process_error_reply(ngx_http_redis2_ctx_t *ctx,
        ssize_t bytes)
{
    /* TODO */
    return NGX_OK;
}


ngx_int_t
ngx_http_redis2_process_integer_reply(ngx_http_redis2_ctx_t *ctx,
        ssize_t bytes)
{
    /* TODO */
    return NGX_OK;
}


ngx_int_t
ngx_http_redis2_process_bulk_reply(ngx_http_redis2_ctx_t *ctx,
        ssize_t bytes)
{
    /* TODO */
    return NGX_OK;
}


ngx_int_t
ngx_http_redis2_process_multi_bulk_reply(ngx_http_redis2_ctx_t *ctx,
        ssize_t bytes)
{
    /* TODO */
    return NGX_OK;
}

