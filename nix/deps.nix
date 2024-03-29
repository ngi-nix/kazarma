{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    bunt = buildMix rec {
      name = "bunt";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lw3v9kwbbcy1v6ygziiky887gffwwmxvyg4r1v0zm71kzhcgxbs";
      };

      beamDeps = [];
    };

    cachex = buildMix rec {
      name = "cachex";
      version = "3.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rfbbij81zmk6p75z33wg04mfcjqsxzzh67vclllvfjgmfqj609p";
      };

      beamDeps = [ eternal jumper sleeplocks unsafe ];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.6.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0zmvagzisnk7lj5pfipl19mjq9wn70i339hpbkfljf0vk6s9fk2j";
      };

      beamDeps = [];
    };

    cldr_utils = buildMix rec {
      name = "cldr_utils";
      version = "2.16.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ivvgypfid82rg2gy2k0q1lxmfhffv7jd9xxp2jaarp5vw7xrx9y";
      };

      beamDeps = [ certifi decimal ];
    };

    cobertura_cover = buildMix rec {
      name = "cobertura_cover";
      version = "0.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1cd0pvbbnbz7lgl7h0p0qhnls8r5i5l6n87i2c6wiidciijw82w7";
      };

      beamDeps = [];
    };

    combine = buildMix rec {
      name = "combine";
      version = "0.10.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "06s5y8b0snr1s5ax9v3s7rc6c8xf5vj6878d1mc7cc07j0bvq78v";
      };

      beamDeps = [];
    };

    connection = buildMix rec {
      name = "connection";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1746n8ba11amp1xhwzp38yfii2h051za8ndxlwdykyqqljq1wb3j";
      };

      beamDeps = [];
    };

    cowboy = buildErlangMk rec {
      name = "cowboy";
      version = "2.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1phv0a1zbgk7imfgcm0dlacm7hbjcdygb0pqmx4s26jf9f9rywic";
      };

      beamDeps = [ cowlib ranch ];
    };

    cowlib = buildRebar3 rec {
      name = "cowlib";
      version = "2.11.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ac6pj3x4vdbsa8hvmbzpdfc4k0v1p102jbd39snai8wnah9sgib";
      };

      beamDeps = [];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "14kniigjhzwnx5r080x1lv5gs80ksjh1yafqwm6m0xxdi4lqlpqm";
      };

      beamDeps = [ bunt jason ];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1j6psw0dxq1175b6zcqpm6vavv4n6sv72ji57l8b6qczmlhnqhdd";
      };

      beamDeps = [ connection telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xzm8hfhn8q02rmg8cpgs68n5jz61wvqg7bxww9i1a6yanf6wril";
      };

      beamDeps = [];
    };

    dialyxir = buildMix rec {
      name = "dialyxir";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0m26cpw56gq1q47x1w7p5jy3sxaj5la1l1nq13519b2z2j46bc5f";
      };

      beamDeps = [ erlex ];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.15";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0p6a442517w79j7q8fvyqb9n31h03cifqxy8iqdrr8cf8gb26i84";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.7.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0f463fw0mydnk7vsy7rinsly85lpbn3f3nylzx66b7j7zhwmnvnk";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0w0gqvmlyyh7avxfwqg79xd579mv4px4qilcj9xgi6yrl7gkaqd2";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    erlex = buildMix rec {
      name = "erlex";
      version = "0.2.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0x8c1j62y748ldvlh46sxzv5514rpzm809vxn594vd7y25by5lif";
      };

      beamDeps = [];
    };

    eternal = buildMix rec {
      name = "eternal";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "10p7m6kv2z2c16gw36wgiwnkykss4lfkmm71llxp09ipkhmy77rc";
      };

      beamDeps = [];
    };

    ex_cldr = buildMix rec {
      name = "ex_cldr";
      version = "2.23.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1x5qjsn52smhbgz1vmanr2nr8bwpnr1ffayv3dsspizxsg407knr";
      };

      preBuild = ''
          echo "import Config" > config/prod.exs
      '';

      beamDeps = [ certifi cldr_utils decimal gettext jason nimble_parsec plug ];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.25.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1mlkldc8q9shjn22kgzgjldcg3i38nhm4b8mzm6z29xchwp1f32v";
      };

      beamDeps = [ earmark_parser makeup_elixir makeup_erlang ];
    };

    flexto = buildMix rec {
      name = "flexto";
      version = "0.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "06v8qv9is2wr3by53micq1g810w16sjlimh88jyf4k6w9idqghd3";
      };

      beamDeps = [ ecto ];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.18.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1igmn69xzj5wpkblg3k9v7wa2fjc2j0cncwx0grk1pag7nqkgxgr";
      };

      beamDeps = [];
    };

    hackney = buildRebar3 rec {
      name = "hackney";
      version = "1.17.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05kbk3rpw2j3cb9pybikydxmi2nm5pidpx0jsm48av2mjr4zy5ny";
      };

      beamDeps = [ certifi idna metrics mimerl parse_trans ssl_verify_fun unicode_util_compat ];
    };

    httpoison = buildMix rec {
      name = "httpoison";
      version = "1.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0fiwkdrbj7mmz449skp7laz2jdwsqn3svddncmicd46gk2m9w218";
      };

      beamDeps = [ hackney ];
    };

    idna = buildRebar3 rec {
      name = "idna";
      version = "6.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sjcjibl34sprpf1dgdmzfww24xlyy34lpj7mhcys4j4i6vnwdwj";
      };

      beamDeps = [ unicode_util_compat ];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0y91s7q8zlfqd037c1mhqdhrvrf60l4ax7lzya1y33h5y3sji8hq";
      };

      beamDeps = [ decimal ];
    };

    jumper = buildMix rec {
      name = "jumper";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0cvlbfkapkvbwaijmjq3cxg5m6yv4rh69wvss9kfj862i83mk31i";
      };

      beamDeps = [];
    };

    junit_formatter = buildMix rec {
      name = "junit_formatter";
      version = "3.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0rm6hzlm5wdd497ywywi7gjypkd0hkl42zacmrav292kj880812d";
      };

      beamDeps = [];
    };

    makeup = buildMix rec {
      name = "makeup";
      version = "1.0.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1a9cp9zp85yfybhdxapi9haa1yykzq91bw8abmk0qp1z5p05i8fg";
      };

      beamDeps = [ nimble_parsec ];
    };

    makeup_elixir = buildMix rec {
      name = "makeup_elixir";
      version = "0.15.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1j3fdjp915nq44c55gwysscryyqivjnaaign0wman1sb4drw2s6v";
      };

      beamDeps = [ makeup nimble_parsec ];
    };

    makeup_erlang = buildMix rec {
      name = "makeup_erlang";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1fvw0zr7vqd94vlj62xbqh0yrih1f7wwnmlj62rz0klax44hhk8p";
      };

      beamDeps = [ makeup ];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05lz15piphyhvvm3d1ldjyw0zsrvz50d2m5f2q3s8x2gvkfrmc39";
      };

      beamDeps = [];
    };

    mime = buildMix rec {
      name = "mime";
      version = "1.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19qrpnmaf3w8bblvkv6z5g82hzd10rhc7bqxvqyi88c37xhsi89i";
      };

      beamDeps = [];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08wkw73dy449n68ssrkz57gikfzqk3vfnf264s31jn5aa1b5hy7j";
      };

      beamDeps = [];
    };

    mox = buildMix rec {
      name = "mox";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pzlqq9y4i9i7d0dm8ah2c5a7y2h9649gkz9hfqamnmbnwh0l6r0";
      };

      beamDeps = [];
    };

    mutex = buildMix rec {
      name = "mutex";
      version = "1.1.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0gpzqd0mq6q8wgwmnk69qv4y7pz8nmrp0lnx4cf63lmdhhkvk0rb";
      };

      beamDeps = [];
    };

    nimble_parsec = buildMix rec {
      name = "nimble_parsec";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0jzmr0x3s6z16c74gvrk9aqc10brn6a1dwa8ywzr2vkhdgb35sq8";
      };

      beamDeps = [];
    };

    oban = buildMix rec {
      name = "oban";
      version = "2.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wx5009rwj3a2bs9ffsq81i9dqkh7bfs6wh7ghhw8z4g86na4m19";
      };

      beamDeps = [ ecto_sql jason postgrex telemetry ];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12w8ai6b5s6b4hnvkav7hwxd846zdd74r32f84nkcmjzi1vrbk87";
      };

      beamDeps = [];
    };

    phoenix = buildMix rec {
      name = "phoenix";
      version = "1.5.12";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04s16a1hjlwjkdkq4gz4xacvhvy4xcpiw5kccjmbn66c9xryc2lg";
      };

      beamDeps = [ jason phoenix_html phoenix_pubsub plug plug_cowboy plug_crypto telemetry ];
    };

    phoenix_ecto = buildMix rec {
      name = "phoenix_ecto";
      version = "4.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1h9wnjmxns8y8dsr0r41ks66gscaqm7ivk4gsh5y07nkiralx1h9";
      };

      beamDeps = [ ecto phoenix_html plug ];
    };

    phoenix_html = buildMix rec {
      name = "phoenix_html";
      version = "2.14.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03z8r285znlg25yi47d4l59s7jq58y4dnhvbxgp16npkzykrgmpg";
      };

      beamDeps = [ plug ];
    };

    phoenix_live_dashboard = buildMix rec {
      name = "phoenix_live_dashboard";
      version = "0.2.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0s291fziphdf9qxxdbphn6wd2id1ccxv666z2l7m6q4aan6rahcq";
      };

      beamDeps = [ phoenix_html phoenix_live_view telemetry_metrics ];
    };

    phoenix_live_view = buildMix rec {
      name = "phoenix_live_view";
      version = "0.14.8";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1690gay6p48wb2lg7s2ip386p73dx11h910vzn2gx9hkq6yn15l8";
      };

      beamDeps = [ jason phoenix phoenix_html telemetry ];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wgpa19l6xar0k2m117iz2kq3cw433llp07sqswpf5969y698bf5";
      };

      beamDeps = [];
    };

    plug = buildMix rec {
      name = "plug";
      version = "1.12.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "02ykw1666amp8mjzfwgm155fp4fszg2nv5l4nya09hkvfyd7jznm";
      };

      beamDeps = [ mime plug_crypto telemetry ];
    };

    plug_cowboy = buildMix rec {
      name = "plug_cowboy";
      version = "2.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0zmrlw15riwgvfncrr3m45q7znq4d3cmdpq33sf3zwfff0c5lndw";
      };

      beamDeps = [ cowboy plug telemetry ];
    };

    plug_crypto = buildMix rec {
      name = "plug_crypto";
      version = "1.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1nxnxj62iv4yvm4771jbxpj3l4brn2crz053y12s998lv5x1qqw7";
      };

      beamDeps = [];
    };

    pointers = buildMix rec {
      name = "pointers";
      version = "0.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12l15qzm7hc68lfkddbr90ka2rmyl9crn0kbid88l00izasivs0f";
      };

      beamDeps = [ ecto_sql flexto pointers_ulid ];
    };

    pointers_ulid = buildMix rec {
      name = "pointers_ulid";
      version = "0.2.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0nyysgz5r1ax1355jmfpj76a10nfsx026xih141j5bx9jb46gjjw";
      };

      beamDeps = [ ecto ecto_sql ];
    };

    polyjuice_util = buildMix rec {
      name = "polyjuice_util";
      version = "0.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1md8356fi0sf3cnxb6cx4zdbybcs4i4pqnhzkajivkjj9xhiypdg";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.15.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1gijc67mnxi80vsxgsw4rpdircx3w4x670g2z09v5xj2fm1clq0m";
      };

      beamDeps = [ connection db_connection decimal jason ];
    };

    ranch = buildRebar3 rec {
      name = "ranch";
      version = "1.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rfz5ld54pkd2w25jadyznia2vb7aw9bclck21fizargd39wzys9";
      };

      beamDeps = [];
    };

    sleeplocks = buildRebar3 rec {
      name = "sleeplocks";
      version = "1.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q823i5bisc83pyssgrqkggyxiasm7b8dygzj2r943adzyp3gvl4";
      };

      beamDeps = [];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1026l1z1jh25z8bfrhaw0ryk5gprhrpnirq877zqhg253x3x5c5x";
      };

      beamDeps = [];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "0.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0hc0fr2bh97wah9ycpm7hb5jdqr5hnl1s3b2ibbbx9gxbwvbhwpb";
      };

      beamDeps = [];
    };

    telemetry_metrics = buildMix rec {
      name = "telemetry_metrics";
      version = "0.6.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1iilk2n75kn9i95fdp8mpxvn3rcn3ghln7p77cijqws13j3y1sbv";
      };

      beamDeps = [ telemetry ];
    };

    telemetry_poller = buildRebar3 rec {
      name = "telemetry_poller";
      version = "0.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1m1zcq65yz0wp1wx7mcy2iq37cyizbzrmv0c11x6xg0hj8375asc";
      };

      beamDeps = [ telemetry ];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11h3fnsmkwjbhvs70rjqljfzinvsr4hg6c99yx56ckdzcjv5nxg0";
      };

      beamDeps = [ hackney jason mime telemetry ];
    };

    timex = buildMix rec {
      name = "timex";
      version = "3.7.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12f5w9i3msv5nc51zcwyrh875vb2wrb8qscnp2awf7nbg5zk55m2";
      };

      beamDeps = [ combine gettext tzdata ];
    };

    tzdata = buildMix rec {
      name = "tzdata";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0d20s66kr7yqjrsp0b7ym85v8aqivk90d28frxdxrls8kdrm7x0q";
      };

      beamDeps = [ hackney ];
    };

    unicode_util_compat = buildRebar3 rec {
      name = "unicode_util_compat";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08952lw8cjdw8w171lv8wqbrxc4rcmb3jhkrdb7n06gngpbfdvi5";
      };

      beamDeps = [];
    };

    unsafe = buildMix rec {
      name = "unsafe";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rahpgz1lsd66r7ycns1ryz2qymamz1anrlps986900lsai2jxvc";
      };

      beamDeps = [];
    };

    uuid = buildMix rec {
      name = "uuid";
      version = "1.1.8";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1b7jjbkmp42rayl6nif6qirksnxgxzksm2rpq9fiyq1v9hxmk467";
      };

      beamDeps = [];
    };
  };
in self

