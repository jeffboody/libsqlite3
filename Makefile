TARGET   = libsqlite3.a
CLASSES  = sqlite3
SOURCE   = $(CLASSES:%=%.c)
OBJECTS  = $(SOURCE:.c=.o)
HFILES   = $(CLASSES:%=%.h)
OPT      = -Os -Wall
CFLAGS   = \
	$(OPT) -I.                   \
	-DSQLITE_ENABLE_RTREE=1      \
	-DSQLITE_ENABLE_FTS3         \
	-DSQLITE_ENABLE_FTS3_PARENTHESIS
LDFLAGS  =
AR       = ar

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(AR) rcs $@ $(OBJECTS)

clean:
	rm -f $(OBJECTS) *~ \#*\# $(TARGET)

$(OBJECTS): $(HFILES)
