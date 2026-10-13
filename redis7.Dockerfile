FROM redis:7.2-alpine

# CMD, not ENTRYPOINT: keep the stock docker-entrypoint.sh, which adds --protected-mode no
# (without it Redis refuses clients from other services) and chowns /data on a fresh volume.
CMD ["redis-server", "--maxmemory-policy", "allkeys-lru", "--maxmemory", "200mb"]
