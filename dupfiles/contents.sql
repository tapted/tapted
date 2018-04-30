CREATE TABLE file (
  path VARCHAR PRIMARY KEY,
  size BIGINT,
  nbyte BIGINT,
  hash STRING
);
CREATE INDEX file_hash_idx ON file (hash);
CREATE INDEX file_path_hash_idx ON file(size, hash);
CREATE INDEX file_path_idx ON file (size);
