CREATE OR REPLACE PACKAGE SYS.DBMS_CRYPTO AS

    ---------------------------------------------------------------------------
    --
    -- PACKAGE NOTES
    --
    -- DBMS_CRYPTO contains basic cryptographic functions and
    -- procedures.  To use correctly and securely, a general level of
    -- security expertise is assumed.
    --
    -- VARCHAR2 datatype is not supported.  Cryptographic operations
    -- on this type should be prefaced with conversions to a uniform
    -- character set (AL32UTF8) and conversion to RAW type.
    --
    -- Prior to encryption, hashing or keyed hashing, CLOB datatype is
    -- converted to AL32UTF8.  This allows cryptographic data to be
    -- transferred and understood between databases with different
    -- character sets, across character set changes and between
    -- separate processes (for example, Java programs).
    --
    ---------------------------------------------------------------------------


    -------------------------- ALGORITHM CONSTANTS ----------------------------
    -- The following constants refer to various types of cryptographic
    -- functions available from this package.  Some of the constants
    -- represent modifiers to these algorithms.
    ---------------------------------------------------------------------------

    -- Hash Functions
    HASH_MD4           CONSTANT PLS_INTEGER            :=     1;
    HASH_MD5           CONSTANT PLS_INTEGER            :=     2;
    HASH_SH1           CONSTANT PLS_INTEGER            :=     3;

    -- MAC Functions
    HMAC_MD5           CONSTANT PLS_INTEGER            :=     1;
    HMAC_SH1           CONSTANT PLS_INTEGER            :=     2;

    -- Block Cipher Algorithms
    ENCRYPT_DES        CONSTANT PLS_INTEGER            :=     1;  -- 0x0001
    ENCRYPT_3DES_2KEY  CONSTANT PLS_INTEGER            :=     2;  -- 0x0002
    ENCRYPT_3DES       CONSTANT PLS_INTEGER            :=     3;  -- 0x0003
    ENCRYPT_AES        CONSTANT PLS_INTEGER            :=     4;  -- 0x0004
    ENCRYPT_PBE_MD5DES CONSTANT PLS_INTEGER            :=     5;  -- 0x0005
    ENCRYPT_AES128     CONSTANT PLS_INTEGER            :=     6;  -- 0x0006
    ENCRYPT_AES192     CONSTANT PLS_INTEGER            :=     7;  -- 0x0007
    ENCRYPT_AES256     CONSTANT PLS_INTEGER            :=     8;  -- 0x0008

    -- Block Cipher Chaining Modifiers
    CHAIN_CBC          CONSTANT PLS_INTEGER            :=   256;  -- 0x0100
    CHAIN_CFB          CONSTANT PLS_INTEGER            :=   512;  -- 0x0200
    CHAIN_ECB          CONSTANT PLS_INTEGER            :=   768;  -- 0x0300
    CHAIN_OFB          CONSTANT PLS_INTEGER            :=  1024;  -- 0x0400

    -- Block Cipher Padding Modifiers
    PAD_PKCS5          CONSTANT PLS_INTEGER            :=  4096;  -- 0x1000
    PAD_NONE           CONSTANT PLS_INTEGER            :=  8192;  -- 0x2000
    PAD_ZERO           CONSTANT PLS_INTEGER            := 12288;  -- 0x3000
    PAD_ORCL           CONSTANT PLS_INTEGER            := 16384;  -- 0x4000

    -- Stream Cipher Algorithms
    ENCRYPT_RC4        CONSTANT PLS_INTEGER            :=   129;  -- 0x0081


    -- Convenience Constants for Block Ciphers
    DES_CBC_PKCS5      CONSTANT PLS_INTEGER            := ENCRYPT_DES
                                                          + CHAIN_CBC
                                                          + PAD_PKCS5;

    DES3_CBC_PKCS5     CONSTANT PLS_INTEGER            := ENCRYPT_3DES
                                                          + CHAIN_CBC
                                                          + PAD_PKCS5;

    AES_CBC_PKCS5      CONSTANT PLS_INTEGER            := ENCRYPT_AES
                                                          + CHAIN_CBC
                                                          + PAD_PKCS5;


    ----------------------------- EXCEPTIONS ----------------------------------
    -- Invalid Cipher Suite
    CipherSuiteInvalid EXCEPTION;
    PRAGMA EXCEPTION_INIT(CipherSuiteInvalid, -28827);

    -- Null Cipher Suite
    CipherSuiteNull EXCEPTION;
    PRAGMA EXCEPTION_INIT(CipherSuiteNull,    -28829);

    -- Key Null
    KeyNull EXCEPTION;
    PRAGMA EXCEPTION_INIT(KeyNull,            -28239);

    -- Key Bad Size
    KeyBadSize EXCEPTION;
    PRAGMA EXCEPTION_INIT(KeyBadSize,         -28234);

    -- Double Encryption
    DoubleEncryption EXCEPTION;
    PRAGMA EXCEPTION_INIT(DoubleEncryption,   -28233);


    ---------------------- FUNCTIONS AND PROCEDURES ------------------------

    ------------------------------------------------------------------------
    --
    -- NAME:  Encrypt
    --
    -- DESCRIPTION:
    --
    --   Encrypt plain text data using stream or block cipher with user
    --   supplied key and optional iv.
    --
    -- PARAMETERS
    --
    --   plaintext   - Plaintext data to be encrypted
    --   crypto_type - Stream or block cipher type plus modifiers
    --   key         - Key to be used for encryption
    --   iv          - Optional IV for block ciphers.  Default all zeros.
    --
    -- USAGE NOTES:
    --
    --   Block ciphers may be modified with chaining type (CBC most
    --   common) and padding type (PKCS5 recommended).  Of the four
    --   common data formats, three have been provided: RAW, BLOB,
    --   CLOB. For VARCHAR2 encryption, callers should first convert
    --   to AL32UTF8 character set and then encrypt.
    --
    --     Encrypt(UTL_RAW.CAST_TO_RAW(CONVERT(src,'AL32UTF8')),typ,key);
    --
    --   As return type for encrypt is RAW, callers should consider
    --   encoding it with RAWTOHEX or UTL_ENCODE.BASE64_ENCODE to make
    --   it suitable for VARCHAR2 storage.  These functions expand
    --   data size by 2 and 4/3, respectively.
    --
    --   To improve readability, callers should define their own
    --   package level constants to represent the ciphersuites used
    --   for encryption and decryption.
    --
    --   For example:
    --
    --   DES_CBC_PKCS5 CONSTANT PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_DES
    --                                       + DBMS_CRYPTO.CHAIN_CBC
    --                                       + DBMS_CRYPTO.PAD_PKCS5;
    --
    --
    -- STREAM CIPHERS (RC4) ARE NOT RECOMMENDED FOR STORED DATA ENCRYPTION.
    --
    --
    ------------------------------------------------------------------------

    FUNCTION  Encrypt (src IN            RAW,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL)
      RETURN RAW;

    PROCEDURE Encrypt (dst IN OUT NOCOPY BLOB,
                       src IN            BLOB,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL);

    PROCEDURE Encrypt (dst IN OUT NOCOPY BLOB,
                       src IN            CLOB         CHARACTER SET ANY_CS,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL);


    ------------------------------------------------------------------------
    --
    -- NAME:  Decrypt
    --
    -- DESCRIPTION:
    --
    --   Decrypt crypt text data using stream or block cipher with user
    --   supplied key and optional iv.
    --
    -- PARAMETERS
    --
    --   cryptext    - Crypt text data to be decrypted
    --   crypto_type - Stream or block cipher type plus modifiers
    --   key         - Key to be used for encryption
    --   iv          - Optional IV for block ciphers.  Default all zeros.
    --
    -- USAGE NOTES:
    --   To retrieve original plain text data, Decrypt must be called
    --   with the same cipher, modifiers, key and iv used for
    --   encryption.  If crypt text data was converted to hex or
    --   base64 prior to storage, it must be decoded using HEXTORAW or
    --   UTL_ENCODE.BASE64_DECODE prior to decryption.
    --
    ------------------------------------------------------------------------

    FUNCTION  Decrypt (src IN            RAW,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL)
       RETURN RAW;

    PROCEDURE Decrypt (dst IN OUT NOCOPY BLOB,
                       src IN            BLOB,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL);

    PROCEDURE Decrypt (dst IN OUT NOCOPY CLOB         CHARACTER SET ANY_CS,
                       src IN            BLOB,
                       typ IN            PLS_INTEGER,
                       key IN            RAW,
                       iv  IN            RAW          DEFAULT NULL);


    ------------------------------------------------------------------------
    --
    -- NAME:  Hash
    --
    -- DESCRIPTION:
    --
    --   Hash source data by cryptographic hash type.
    --
    -- PARAMETERS
    --
    --   source    - Source data to be hashed
    --   hash_type - Hash algorithm to be used
    --
    -- USAGE NOTES:
    --   SHA-1 (HASH_SH1) is recommended.  Consider encoding returned
    --   raw value to hex or base64 prior to storage.
    --
    ------------------------------------------------------------------------

    FUNCTION Hash (src IN RAW,
                   typ IN PLS_INTEGER)
      RETURN RAW DETERMINISTIC;

    FUNCTION Hash (src IN BLOB,
                   typ IN PLS_INTEGER)
      RETURN RAW DETERMINISTIC;

    FUNCTION Hash (src IN CLOB        CHARACTER SET ANY_CS,
                   typ IN PLS_INTEGER)
      RETURN RAW DETERMINISTIC;


    ------------------------------------------------------------------------
    --
    -- NAME:  Mac
    --
    -- DESCRIPTION:
    --
    --   Message Authentication Code algorithms provide keyed message
    --   protection.
    --
    -- PARAMETERS
    --
    --   source   - Source data to be mac-ed
    --   mac_type - Mac algorithm to be used
    --   key      - Key to be used for mac
    --
    -- USAGE NOTES:
    --   Callers should consider encoding returned raw value to hex or
    --   base64 prior to storage.
    --
    ------------------------------------------------------------------------
    FUNCTION Mac (src IN RAW,
                  typ IN PLS_INTEGER,
                  key IN RAW)
      RETURN RAW;

    FUNCTION Mac (src IN BLOB,
                  typ IN PLS_INTEGER,
                  key IN RAW)
      RETURN RAW;

    FUNCTION Mac (src IN CLOB         CHARACTER SET ANY_CS,
                  typ IN PLS_INTEGER,
                  key IN RAW)
      RETURN RAW;


    ------------------------------------------------------------------------
    --
    -- NAME:  RandomBytes
    --
    -- DESCRIPTION:
    --
    --   Returns a raw value containing a pseudo-random sequence of
    --   bytes.
    --
    -- PARAMETERS
    --
    --   number_bytes - Number of pseudo-random bytes to be generated.
    --
    -- USAGE NOTES:
    --   number_bytes should not exceed maximum RAW length.
    --
    ------------------------------------------------------------------------
    FUNCTION RandomBytes (number_bytes IN PLS_INTEGER)
      RETURN RAW;


    ------------------------------------------------------------------------
    --
    -- NAME:  RandomNumber
    --
    -- DESCRIPTION:
    --
    --   Returns a random Oracle Number.
    --
    -- PARAMETERS
    --
    --  None.
    --
    ------------------------------------------------------------------------
    FUNCTION RandomNumber
      RETURN NUMBER;


    ------------------------------------------------------------------------
    --
    -- NAME:  RandomInteger
    --
    -- DESCRIPTION:
    --
    --   Returns a random BINARY_INTEGER.
    --
    -- PARAMETERS
    --
    --  None.
    --
    ------------------------------------------------------------------------
    FUNCTION RandomInteger
      RETURN BINARY_INTEGER;


    PRAGMA RESTRICT_REFERENCES(DEFAULT, WNDS, RNDS, WNPS, RNPS);

END DBMS_CRYPTO;
/
