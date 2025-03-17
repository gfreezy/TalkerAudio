import Testing

@testable import TalkerAudio

@Test("testJson")
func testJson() throws {
  let json = """
    {
      "data": "I'm speaking on this topic. First one pops in my mind is the first time we went to elementary school in there. They first pops of feeling is sadness and fear nice in their day and the youngest children.King of houses and in the usual I spend the most time with my family and also I just go to the king garden for about one year so I I'm not spend too much time with his classmate or to make friends also I.I think I'm introverted person so in their day I just can stop crying, adjust can control my control myself but as I made funding classmates also I was started.English boarding school my classmates my classmates are also comforted me, she said you just need to insist it five days you can go back home and I'm so things about her 'cause when I was so sad she your.To comfort to me.",
      "desc": "success",
      "action": "result",
      "accuracy": {
        "text_items": [
          {
            "word_text": "I'm",
            "error_type": "Mispronunciation",
            "accuracy_score": 53,
            "syllables": [
              {
                "accuracy_score": 43,
                "duration": 3600000,
                "grapheme": "i'm",
                "offset": 8200000,
                "syllable": "aɪm"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 23,
                "duration": 1600000,
                "offset": 8200000
              },
              {
                "phoneme": "m",
                "accuracy_score": 60,
                "duration": 1900000,
                "offset": 9900000
              }
            ]
          },
          {
            "word_text": "speaking",
            "error_type": "None",
            "accuracy_score": 74,
            "syllables": [
              {
                "accuracy_score": 69,
                "duration": 2500000,
                "grapheme": "speak",
                "offset": 11900000,
                "syllable": "spi"
              },
              {
                "accuracy_score": 60,
                "duration": 1900000,
                "grapheme": "ing",
                "offset": 14500000,
                "syllable": "kɪŋ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 0,
                "duration": 700000,
                "offset": 11900000
              },
              {
                "phoneme": "p",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 12700000
              },
              {
                "phoneme": "i",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 13900000
              },
              {
                "phoneme": "k",
                "accuracy_score": 100,
                "duration": 300000,
                "offset": 14500000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 14900000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 19,
                "duration": 900000,
                "offset": 15500000
              }
            ]
          },
          {
            "word_text": "on",
            "error_type": "None",
            "accuracy_score": 70,
            "syllables": [
              {
                "accuracy_score": 60,
                "duration": 1200000,
                "grapheme": "on",
                "offset": 16500000,
                "syllable": "ɔn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɔ",
                "accuracy_score": 72,
                "duration": 700000,
                "offset": 16500000
              },
              {
                "phoneme": "n",
                "accuracy_score": 40,
                "duration": 400000,
                "offset": 17300000
              }
            ]
          },
          {
            "word_text": "this",
            "error_type": "None",
            "accuracy_score": 73,
            "syllables": [
              {
                "accuracy_score": 64,
                "duration": 2200000,
                "grapheme": "this",
                "offset": 17800000,
                "syllable": "ðɪs"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 55,
                "duration": 400000,
                "offset": 17800000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 86,
                "duration": 700000,
                "offset": 18300000
              },
              {
                "phoneme": "s",
                "accuracy_score": 52,
                "duration": 900000,
                "offset": 19100000
              }
            ]
          },
          {
            "word_text": "topic.",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 49,
                "duration": 1700000,
                "grapheme": "top",
                "offset": 20100000,
                "syllable": "tɑ"
              },
              {
                "accuracy_score": 89,
                "duration": 5300000,
                "grapheme": "ic",
                "offset": 21900000,
                "syllable": "pɪk"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 16,
                "duration": 900000,
                "offset": 20100000
              },
              {
                "phoneme": "ɑ",
                "accuracy_score": 91,
                "duration": 700000,
                "offset": 21100000
              },
              {
                "phoneme": "p",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 21900000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 23100000
              },
              {
                "phoneme": "k",
                "accuracy_score": 78,
                "duration": 2700000,
                "offset": 24500000
              }
            ]
          },
          {
            "word_text": "First",
            "error_type": "None",
            "accuracy_score": 72,
            "syllables": [
              {
                "accuracy_score": 63,
                "duration": 5500000,
                "grapheme": "first",
                "offset": 28100000,
                "syllable": "fɝrst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 48,
                "duration": 2100000,
                "offset": 28100000
              },
              {
                "phoneme": "ɝ",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 30300000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 30900000
              },
              {
                "phoneme": "s",
                "accuracy_score": 79,
                "duration": 900000,
                "offset": 31700000
              },
              {
                "phoneme": "t",
                "accuracy_score": 27,
                "duration": 900000,
                "offset": 32700000
              }
            ]
          },
          {
            "word_text": "one",
            "error_type": "Mispronunciation",
            "accuracy_score": 41,
            "syllables": [
              {
                "accuracy_score": 33,
                "duration": 2300000,
                "grapheme": "one",
                "offset": 33700000,
                "syllable": "wɑn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "w",
                "accuracy_score": 49,
                "duration": 500000,
                "offset": 33700000
              },
              {
                "phoneme": "ɑ",
                "accuracy_score": 74,
                "duration": 500000,
                "offset": 34300000
              },
              {
                "phoneme": "n",
                "accuracy_score": 5,
                "duration": 1100000,
                "offset": 34900000
              }
            ]
          },
          {
            "word_text": "pops",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 78,
                "duration": 3500000,
                "grapheme": "pops",
                "offset": 36100000,
                "syllable": "pɑps"
              }
            ],
            "phonemes": [
              {
                "phoneme": "p",
                "accuracy_score": 87,
                "duration": 700000,
                "offset": 36100000
              },
              {
                "phoneme": "ɑ",
                "accuracy_score": 90,
                "duration": 500000,
                "offset": 36900000
              },
              {
                "phoneme": "p",
                "accuracy_score": 96,
                "duration": 900000,
                "offset": 37500000
              },
              {
                "phoneme": "s",
                "accuracy_score": 51,
                "duration": 1100000,
                "offset": 38500000
              }
            ]
          },
          {
            "word_text": "in",
            "error_type": "None",
            "accuracy_score": 89,
            "syllables": [
              {
                "accuracy_score": 85,
                "duration": 1300000,
                "grapheme": "in",
                "offset": 39700000,
                "syllable": "ɪn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 39700000
              },
              {
                "phoneme": "n",
                "accuracy_score": 65,
                "duration": 500000,
                "offset": 40500000
              }
            ]
          },
          {
            "word_text": "my",
            "error_type": "None",
            "accuracy_score": 91,
            "syllables": [
              {
                "accuracy_score": 88,
                "duration": 900000,
                "grapheme": "my",
                "offset": 41100000,
                "syllable": "maɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 100,
                "duration": 400000,
                "offset": 41100000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 75,
                "duration": 400000,
                "offset": 41600000
              }
            ]
          },
          {
            "word_text": "mind",
            "error_type": "None",
            "accuracy_score": 86,
            "syllables": [
              {
                "accuracy_score": 81,
                "duration": 4100000,
                "grapheme": "mind",
                "offset": 42100000,
                "syllable": "maɪnd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 94,
                "duration": 1300000,
                "offset": 42100000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 43500000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 44500000
              },
              {
                "phoneme": "d",
                "accuracy_score": 12,
                "duration": 700000,
                "offset": 45500000
              }
            ]
          },
          {
            "word_text": "is",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 5500000,
                "grapheme": "is",
                "offset": 46300000,
                "syllable": "ɪz"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1900000,
                "offset": 46300000
              },
              {
                "phoneme": "z",
                "accuracy_score": 100,
                "duration": 3500000,
                "offset": 48300000
              }
            ]
          },
          {
            "word_text": "the",
            "error_type": "None",
            "accuracy_score": 74,
            "syllables": [
              {
                "accuracy_score": 66,
                "duration": 1700000,
                "grapheme": "the",
                "offset": 53900000,
                "syllable": "ðə"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 70,
                "duration": 900000,
                "offset": 53900000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 61,
                "duration": 700000,
                "offset": 54900000
              }
            ]
          },
          {
            "word_text": "first",
            "error_type": "None",
            "accuracy_score": 90,
            "syllables": [
              {
                "accuracy_score": 86,
                "duration": 3500000,
                "grapheme": "first",
                "offset": 55700000,
                "syllable": "fɝrst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 88,
                "duration": 900000,
                "offset": 55700000
              },
              {
                "phoneme": "ɝ",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 56700000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 57300000
              },
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 58100000
              },
              {
                "phoneme": "t",
                "accuracy_score": 0,
                "duration": 300000,
                "offset": 58900000
              }
            ]
          },
          {
            "word_text": "time",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 78,
                "duration": 6900000,
                "grapheme": "time",
                "offset": 59300000,
                "syllable": "taɪm"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 67,
                "duration": 1300000,
                "offset": 59300000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 84,
                "duration": 900000,
                "offset": 60700000
              },
              {
                "phoneme": "m",
                "accuracy_score": 80,
                "duration": 4500000,
                "offset": 61700000
              }
            ]
          },
          {
            "word_text": "we",
            "error_type": "Mispronunciation",
            "accuracy_score": 54,
            "syllables": [
              {
                "accuracy_score": 44,
                "duration": 2400000,
                "grapheme": "we",
                "offset": 72500000,
                "syllable": "wi"
              }
            ],
            "phonemes": [
              {
                "phoneme": "w",
                "accuracy_score": 44,
                "duration": 2100000,
                "offset": 72500000
              },
              {
                "phoneme": "i",
                "accuracy_score": 40,
                "duration": 200000,
                "offset": 74700000
              }
            ]
          },
          {
            "word_text": "went",
            "error_type": "None",
            "accuracy_score": 63,
            "syllables": [
              {
                "accuracy_score": 53,
                "duration": 3200000,
                "grapheme": "went",
                "offset": 75000000,
                "syllable": "wɛnt"
              }
            ],
            "phonemes": [
              {
                "phoneme": "w",
                "accuracy_score": 0,
                "duration": 200000,
                "offset": 75000000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 77,
                "duration": 700000,
                "offset": 75300000
              },
              {
                "phoneme": "n",
                "accuracy_score": 81,
                "duration": 1300000,
                "offset": 76100000
              },
              {
                "phoneme": "t",
                "accuracy_score": 0,
                "duration": 700000,
                "offset": 77500000
              }
            ]
          },
          {
            "word_text": "to",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 7000000,
                "grapheme": "to",
                "offset": 78300000,
                "syllable": "tu"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 78300000
              },
              {
                "phoneme": "u",
                "accuracy_score": 100,
                "duration": 5600000,
                "offset": 79700000
              }
            ]
          },
          {
            "word_text": "elementary",
            "error_type": "None",
            "accuracy_score": 88,
            "syllables": [
              {
                "accuracy_score": 50,
                "duration": 1300000,
                "grapheme": "e",
                "offset": 88500000,
                "syllable": "ɛ"
              },
              {
                "accuracy_score": 95,
                "duration": 1100000,
                "grapheme": "le",
                "offset": 89900000,
                "syllable": "lə"
              },
              {
                "accuracy_score": 97,
                "duration": 1700000,
                "grapheme": "men",
                "offset": 91100000,
                "syllable": "mɛn"
              },
              {
                "accuracy_score": 90,
                "duration": 2000000,
                "grapheme": "tary",
                "offset": 92900000,
                "syllable": "tri"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɛ",
                "accuracy_score": 50,
                "duration": 1300000,
                "offset": 88500000
              },
              {
                "phoneme": "l",
                "accuracy_score": 90,
                "duration": 500000,
                "offset": 89900000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 90500000
              },
              {
                "phoneme": "m",
                "accuracy_score": 90,
                "duration": 400000,
                "offset": 91100000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 100,
                "duration": 400000,
                "offset": 91600000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 92100000
              },
              {
                "phoneme": "t",
                "accuracy_score": 98,
                "duration": 700000,
                "offset": 92900000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 93700000
              },
              {
                "phoneme": "i",
                "accuracy_score": 73,
                "duration": 600000,
                "offset": 94300000
              }
            ]
          },
          {
            "word_text": "school",
            "error_type": "None",
            "accuracy_score": 95,
            "syllables": [
              {
                "accuracy_score": 93,
                "duration": 5700000,
                "grapheme": "school",
                "offset": 95000000,
                "syllable": "skul"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 800000,
                "offset": 95000000
              },
              {
                "phoneme": "k",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 95900000
              },
              {
                "phoneme": "u",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 97100000
              },
              {
                "phoneme": "l",
                "accuracy_score": 86,
                "duration": 2600000,
                "offset": 98100000
              }
            ]
          },
          {
            "word_text": "in",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 3100000,
                "grapheme": "in",
                "offset": 108900000,
                "syllable": "ɪn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 2100000,
                "offset": 108900000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 111100000
              }
            ]
          },
          {
            "word_text": "there.",
            "error_type": "None",
            "accuracy_score": 87,
            "syllables": [
              {
                "accuracy_score": 83,
                "duration": 2100000,
                "grapheme": "there",
                "offset": 112100000,
                "syllable": "ðɛr"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 112100000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 100,
                "duration": 600000,
                "offset": 112700000
              },
              {
                "phoneme": "r",
                "accuracy_score": 59,
                "duration": 800000,
                "offset": 113400000
              }
            ]
          },
          {
            "word_text": "They",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 8700000,
                "grapheme": "they",
                "offset": 114300000,
                "syllable": "ðeɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 114300000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 100,
                "duration": 7500000,
                "offset": 115500000
              }
            ]
          },
          {
            "word_text": "first",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 78,
                "duration": 9200000,
                "grapheme": "first",
                "offset": 133800000,
                "syllable": "fɝrst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 62,
                "duration": 3200000,
                "offset": 133800000
              },
              {
                "phoneme": "ɝ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 137100000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 137900000
              },
              {
                "phoneme": "s",
                "accuracy_score": 78,
                "duration": 900000,
                "offset": 139300000
              },
              {
                "phoneme": "t",
                "accuracy_score": 80,
                "duration": 2700000,
                "offset": 140300000
              }
            ]
          },
          {
            "word_text": "pops",
            "error_type": "None",
            "accuracy_score": 77,
            "syllables": [
              {
                "accuracy_score": 69,
                "duration": 6100000,
                "grapheme": "pops",
                "offset": 144900000,
                "syllable": "pɑps"
              }
            ],
            "phonemes": [
              {
                "phoneme": "p",
                "accuracy_score": 50,
                "duration": 1300000,
                "offset": 144900000
              },
              {
                "phoneme": "ɑ",
                "accuracy_score": 73,
                "duration": 900000,
                "offset": 146300000
              },
              {
                "phoneme": "p",
                "accuracy_score": 78,
                "duration": 900000,
                "offset": 147300000
              },
              {
                "phoneme": "s",
                "accuracy_score": 74,
                "duration": 2700000,
                "offset": 148300000
              }
            ]
          },
          {
            "word_text": "of",
            "error_type": "None",
            "accuracy_score": 92,
            "syllables": [
              {
                "accuracy_score": 90,
                "duration": 2200000,
                "grapheme": "of",
                "offset": 154600000,
                "syllable": "əv"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 1400000,
                "offset": 154600000
              },
              {
                "phoneme": "v",
                "accuracy_score": 70,
                "duration": 700000,
                "offset": 156100000
              }
            ]
          },
          {
            "word_text": "feeling",
            "error_type": "None",
            "accuracy_score": 86,
            "syllables": [
              {
                "accuracy_score": 78,
                "duration": 2300000,
                "grapheme": "fee",
                "offset": 156900000,
                "syllable": "fi"
              },
              {
                "accuracy_score": 83,
                "duration": 3100000,
                "grapheme": "ling",
                "offset": 159300000,
                "syllable": "lɪŋ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 65,
                "duration": 900000,
                "offset": 156900000
              },
              {
                "phoneme": "i",
                "accuracy_score": 88,
                "duration": 1300000,
                "offset": 157900000
              },
              {
                "phoneme": "l",
                "accuracy_score": 81,
                "duration": 500000,
                "offset": 159300000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 159900000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 69,
                "duration": 1300000,
                "offset": 161100000
              }
            ]
          },
          {
            "word_text": "is",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 4300000,
                "grapheme": "is",
                "offset": 162500000,
                "syllable": "ɪz"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 162500000
              },
              {
                "phoneme": "z",
                "accuracy_score": 100,
                "duration": 3100000,
                "offset": 163700000
              }
            ]
          },
          {
            "word_text": "sadness",
            "error_type": "None",
            "accuracy_score": 78,
            "syllables": [
              {
                "accuracy_score": 60,
                "duration": 4700000,
                "grapheme": "sad",
                "offset": 178100000,
                "syllable": "sæd"
              },
              {
                "accuracy_score": 80,
                "duration": 5100000,
                "grapheme": "ness",
                "offset": 182900000,
                "syllable": "nɪs"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 53,
                "duration": 2700000,
                "offset": 178100000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 81,
                "duration": 1100000,
                "offset": 180900000
              },
              {
                "phoneme": "d",
                "accuracy_score": 52,
                "duration": 700000,
                "offset": 182100000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 182900000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 184100000
              },
              {
                "phoneme": "s",
                "accuracy_score": 60,
                "duration": 2500000,
                "offset": 185500000
              }
            ]
          },
          {
            "word_text": "and",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 6800000,
                "grapheme": "and",
                "offset": 190000000,
                "syllable": "ənd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 2400000,
                "offset": 190000000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 1700000,
                "offset": 192500000
              },
              {
                "phoneme": "d",
                "accuracy_score": 100,
                "duration": 2500000,
                "offset": 194300000
              }
            ]
          },
          {
            "word_text": "fear",
            "error_type": "None",
            "accuracy_score": 83,
            "syllables": [
              {
                "accuracy_score": 77,
                "duration": 5300000,
                "grapheme": "fear",
                "offset": 201000000,
                "syllable": "fir"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 70,
                "duration": 2600000,
                "offset": 201000000
              },
              {
                "phoneme": "i",
                "accuracy_score": 100,
                "duration": 1500000,
                "offset": 203700000
              },
              {
                "phoneme": "r",
                "accuracy_score": 62,
                "duration": 1000000,
                "offset": 205300000
              }
            ]
          },
          {
            "word_text": "nice",
            "error_type": "None",
            "accuracy_score": 74,
            "syllables": [
              {
                "accuracy_score": 66,
                "duration": 4800000,
                "grapheme": "nice",
                "offset": 206400000,
                "syllable": "nis"
              }
            ],
            "phonemes": [
              {
                "phoneme": "n",
                "accuracy_score": 90,
                "duration": 800000,
                "offset": 206400000
              },
              {
                "phoneme": "i",
                "accuracy_score": 72,
                "duration": 500000,
                "offset": 207300000
              },
              {
                "phoneme": "s",
                "accuracy_score": 59,
                "duration": 3300000,
                "offset": 207900000
              }
            ]
          },
          {
            "word_text": "in",
            "error_type": "None",
            "accuracy_score": 98,
            "syllables": [
              {
                "accuracy_score": 97,
                "duration": 2100000,
                "grapheme": "in",
                "offset": 220100000,
                "syllable": "ɪn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 96,
                "duration": 1300000,
                "offset": 220100000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 221500000
              }
            ]
          },
          {
            "word_text": "their",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 79,
                "duration": 1700000,
                "grapheme": "their",
                "offset": 222300000,
                "syllable": "ðɛr"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 300000,
                "offset": 222300000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 88,
                "duration": 700000,
                "offset": 222700000
              },
              {
                "phoneme": "r",
                "accuracy_score": 53,
                "duration": 500000,
                "offset": 223500000
              }
            ]
          },
          {
            "word_text": "day",
            "error_type": "None",
            "accuracy_score": 91,
            "syllables": [
              {
                "accuracy_score": 88,
                "duration": 5900000,
                "grapheme": "day",
                "offset": 224100000,
                "syllable": "deɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "d",
                "accuracy_score": 99,
                "duration": 1100000,
                "offset": 224100000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 85,
                "duration": 4700000,
                "offset": 225300000
              }
            ]
          },
          {
            "word_text": "and",
            "error_type": "None",
            "accuracy_score": 99,
            "syllables": [
              {
                "accuracy_score": 99,
                "duration": 5800000,
                "grapheme": "and",
                "offset": 243000000,
                "syllable": "ən"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 97,
                "duration": 2200000,
                "offset": 243000000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 3500000,
                "offset": 245300000
              }
            ]
          },
          {
            "word_text": "the",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 6900000,
                "grapheme": "the",
                "offset": 248900000,
                "syllable": "ðə"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 248900000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 6100000,
                "offset": 249700000
              }
            ]
          },
          {
            "word_text": "youngest",
            "error_type": "None",
            "accuracy_score": 91,
            "syllables": [
              {
                "accuracy_score": 84,
                "duration": 3300000,
                "grapheme": "young",
                "offset": 260700000,
                "syllable": "jʌŋ"
              },
              {
                "accuracy_score": 91,
                "duration": 6100000,
                "grapheme": "est",
                "offset": 264100000,
                "syllable": "ɡɪst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "j",
                "accuracy_score": 81,
                "duration": 1700000,
                "offset": 260700000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 100,
                "duration": 800000,
                "offset": 262500000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 70,
                "duration": 600000,
                "offset": 263400000
              },
              {
                "phoneme": "ɡ",
                "accuracy_score": 95,
                "duration": 900000,
                "offset": 264100000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1500000,
                "offset": 265100000
              },
              {
                "phoneme": "s",
                "accuracy_score": 99,
                "duration": 900000,
                "offset": 266700000
              },
              {
                "phoneme": "t",
                "accuracy_score": 81,
                "duration": 2500000,
                "offset": 267700000
              }
            ]
          },
          {
            "word_text": "children.King",
            "error_type": "None",
            "accuracy_score": 77,
            "syllables": [
              {
                "accuracy_score": 61,
                "duration": 3300000,
                "grapheme": "chil",
                "offset": 294300000,
                "syllable": "tʃɪl"
              },
              {
                "accuracy_score": 76,
                "duration": 3700000,
                "grapheme": "dren",
                "offset": 297700000,
                "syllable": "drən"
              }
            ],
            "phonemes": [
              {
                "phoneme": "tʃ",
                "accuracy_score": 33,
                "duration": 1500000,
                "offset": 294300000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 85,
                "duration": 900000,
                "offset": 295900000
              },
              {
                "phoneme": "l",
                "accuracy_score": 88,
                "duration": 700000,
                "offset": 296900000
              },
              {
                "phoneme": "d",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 297700000
              },
              {
                "phoneme": "r",
                "accuracy_score": 92,
                "duration": 900000,
                "offset": 298500000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 299500000
              },
              {
                "phoneme": "n",
                "accuracy_score": 41,
                "duration": 1300000,
                "offset": 300100000
              }
            ]
          },
          {
            "word_text": "king",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 79,
                "duration": 3300000,
                "grapheme": "king",
                "offset": 303200000,
                "syllable": "kɪŋ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 0,
                "duration": 200000,
                "offset": 303200000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 90,
                "duration": 1200000,
                "offset": 303500000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 84,
                "duration": 1700000,
                "offset": 304800000
              }
            ]
          },
          {
            "word_text": "of",
            "error_type": "None",
            "accuracy_score": 82,
            "syllables": [
              {
                "accuracy_score": 76,
                "duration": 4100000,
                "grapheme": "of",
                "offset": 306800000,
                "syllable": "ɔv"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɔ",
                "accuracy_score": 91,
                "duration": 2300000,
                "offset": 306800000
              },
              {
                "phoneme": "v",
                "accuracy_score": 56,
                "duration": 1700000,
                "offset": 309200000
              }
            ]
          },
          {
            "word_text": "houses",
            "error_type": "None",
            "accuracy_score": 70,
            "syllables": [
              {
                "accuracy_score": 43,
                "duration": 3500000,
                "grapheme": "hou",
                "offset": 311000000,
                "syllable": "haʊ"
              },
              {
                "accuracy_score": 70,
                "duration": 6500000,
                "grapheme": "ses",
                "offset": 314600000,
                "syllable": "zɪz"
              }
            ],
            "phonemes": [
              {
                "phoneme": "h",
                "accuracy_score": 43,
                "duration": 1700000,
                "offset": 311000000
              },
              {
                "phoneme": "aʊ",
                "accuracy_score": 43,
                "duration": 1700000,
                "offset": 312800000
              },
              {
                "phoneme": "z",
                "accuracy_score": 71,
                "duration": 1700000,
                "offset": 314600000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 78,
                "duration": 1700000,
                "offset": 316400000
              },
              {
                "phoneme": "z",
                "accuracy_score": 64,
                "duration": 2900000,
                "offset": 318200000
              }
            ]
          },
          {
            "word_text": "and",
            "error_type": "None",
            "accuracy_score": 99,
            "syllables": [
              {
                "accuracy_score": 99,
                "duration": 4700000,
                "grapheme": "and",
                "offset": 325600000,
                "syllable": "ənd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 2600000,
                "offset": 325600000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 1200000,
                "offset": 328300000
              },
              {
                "phoneme": "d",
                "accuracy_score": 94,
                "duration": 700000,
                "offset": 329600000
              }
            ]
          },
          {
            "word_text": "in",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 7900000,
                "grapheme": "in",
                "offset": 330400000,
                "syllable": "ɪn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 330400000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 6500000,
                "offset": 331800000
              }
            ]
          },
          {
            "word_text": "the",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 3300000,
                "grapheme": "the",
                "offset": 354400000,
                "syllable": "ðə"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 1500000,
                "offset": 354400000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 1700000,
                "offset": 356000000
              }
            ]
          },
          {
            "word_text": "usual",
            "error_type": "None",
            "accuracy_score": 86,
            "syllables": [
              {
                "accuracy_score": 75,
                "duration": 2300000,
                "grapheme": "u",
                "offset": 357800000,
                "syllable": "ju"
              },
              {
                "accuracy_score": 100,
                "duration": 1600000,
                "grapheme": "su",
                "offset": 360200000,
                "syllable": "ʒu"
              },
              {
                "accuracy_score": 77,
                "duration": 3600000,
                "grapheme": "al",
                "offset": 361900000,
                "syllable": "əl"
              }
            ],
            "phonemes": [
              {
                "phoneme": "j",
                "accuracy_score": 73,
                "duration": 1100000,
                "offset": 357800000
              },
              {
                "phoneme": "u",
                "accuracy_score": 77,
                "duration": 1100000,
                "offset": 359000000
              },
              {
                "phoneme": "ʒ",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 360200000
              },
              {
                "phoneme": "u",
                "accuracy_score": 100,
                "duration": 400000,
                "offset": 361400000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 90,
                "duration": 1600000,
                "offset": 361900000
              },
              {
                "phoneme": "l",
                "accuracy_score": 66,
                "duration": 1900000,
                "offset": 363600000
              }
            ]
          },
          {
            "word_text": "i",
            "error_type": "None",
            "accuracy_score": 94,
            "syllables": [
              {
                "accuracy_score": 92,
                "duration": 5500000,
                "grapheme": "i",
                "offset": 375200000,
                "syllable": "aɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 92,
                "duration": 5500000,
                "offset": 375200000
              }
            ]
          },
          {
            "word_text": "spend",
            "error_type": "None",
            "accuracy_score": 79,
            "syllables": [
              {
                "accuracy_score": 72,
                "duration": 7500000,
                "grapheme": "spend",
                "offset": 384600000,
                "syllable": "spɛnd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 54,
                "duration": 2700000,
                "offset": 384600000
              },
              {
                "phoneme": "p",
                "accuracy_score": 92,
                "duration": 1100000,
                "offset": 387400000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 98,
                "duration": 1100000,
                "offset": 388600000
              },
              {
                "phoneme": "n",
                "accuracy_score": 83,
                "duration": 1000000,
                "offset": 389800000
              },
              {
                "phoneme": "d",
                "accuracy_score": 59,
                "duration": 1200000,
                "offset": 390900000
              }
            ]
          },
          {
            "word_text": "the",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 1300000,
                "grapheme": "the",
                "offset": 392200000,
                "syllable": "ðə"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 392200000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 392800000
              }
            ]
          },
          {
            "word_text": "most",
            "error_type": "None",
            "accuracy_score": 72,
            "syllables": [
              {
                "accuracy_score": 63,
                "duration": 4100000,
                "grapheme": "most",
                "offset": 393600000,
                "syllable": "moʊst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 5,
                "duration": 900000,
                "offset": 393600000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 394600000
              },
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 396000000
              },
              {
                "phoneme": "t",
                "accuracy_score": 0,
                "duration": 500000,
                "offset": 397200000
              }
            ]
          },
          {
            "word_text": "time",
            "error_type": "None",
            "accuracy_score": 88,
            "syllables": [
              {
                "accuracy_score": 84,
                "duration": 3700000,
                "grapheme": "time",
                "offset": 397800000,
                "syllable": "taɪm"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 95,
                "duration": 1700000,
                "offset": 397800000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 399600000
              },
              {
                "phoneme": "m",
                "accuracy_score": 47,
                "duration": 900000,
                "offset": 400600000
              }
            ]
          },
          {
            "word_text": "with",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 2300000,
                "grapheme": "with",
                "offset": 401600000,
                "syllable": "wɪð"
              }
            ],
            "phonemes": [
              {
                "phoneme": "w",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 401600000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 402200000
              },
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 403000000
              }
            ]
          },
          {
            "word_text": "my",
            "error_type": "None",
            "accuracy_score": 97,
            "syllables": [
              {
                "accuracy_score": 96,
                "duration": 1700000,
                "grapheme": "my",
                "offset": 404000000,
                "syllable": "maɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 90,
                "duration": 700000,
                "offset": 404000000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 404800000
              }
            ]
          },
          {
            "word_text": "family",
            "error_type": "None",
            "accuracy_score": 88,
            "syllables": [
              {
                "accuracy_score": 98,
                "duration": 5300000,
                "grapheme": "",
                "offset": 405800000,
                "syllable": "fæm"
              },
              {
                "accuracy_score": 69,
                "duration": 4700000,
                "grapheme": "",
                "offset": 411200000,
                "syllable": "li"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 97,
                "duration": 1700000,
                "offset": 405800000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 407600000
              },
              {
                "phoneme": "m",
                "accuracy_score": 98,
                "duration": 2100000,
                "offset": 409000000
              },
              {
                "phoneme": "l",
                "accuracy_score": 97,
                "duration": 1500000,
                "offset": 411200000
              },
              {
                "phoneme": "i",
                "accuracy_score": 55,
                "duration": 3100000,
                "offset": 412800000
              }
            ]
          },
          {
            "word_text": "and",
            "error_type": "None",
            "accuracy_score": 89,
            "syllables": [
              {
                "accuracy_score": 85,
                "duration": 2300000,
                "grapheme": "and",
                "offset": 425200000,
                "syllable": "ən"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 87,
                "duration": 1500000,
                "offset": 425200000
              },
              {
                "phoneme": "n",
                "accuracy_score": 82,
                "duration": 700000,
                "offset": 426800000
              }
            ]
          },
          {
            "word_text": "also",
            "error_type": "None",
            "accuracy_score": 93,
            "syllables": [
              {
                "accuracy_score": 99,
                "duration": 1500000,
                "grapheme": "al",
                "offset": 427600000,
                "syllable": "ɔl"
              },
              {
                "accuracy_score": 87,
                "duration": 2500000,
                "grapheme": "so",
                "offset": 429200000,
                "syllable": "soʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɔ",
                "accuracy_score": 97,
                "duration": 600000,
                "offset": 427600000
              },
              {
                "phoneme": "l",
                "accuracy_score": 100,
                "duration": 800000,
                "offset": 428300000
              },
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 429200000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 75,
                "duration": 1300000,
                "offset": 430400000
              }
            ]
          },
          {
            "word_text": "i",
            "error_type": "None",
            "accuracy_score": 78,
            "syllables": [
              {
                "accuracy_score": 70,
                "duration": 900000,
                "grapheme": "i",
                "offset": 431800000,
                "syllable": "aɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 70,
                "duration": 900000,
                "offset": 431800000
              }
            ]
          },
          {
            "word_text": "just",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 4300000,
                "grapheme": "just",
                "offset": 432800000,
                "syllable": "dʒʌst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "dʒ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 432800000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 434200000
              },
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 435200000
              },
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 436000000
              }
            ]
          },
          {
            "word_text": "go",
            "error_type": "None",
            "accuracy_score": 72,
            "syllables": [
              {
                "accuracy_score": 63,
                "duration": 2100000,
                "grapheme": "go",
                "offset": 437200000,
                "syllable": "ɡoʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɡ",
                "accuracy_score": 66,
                "duration": 700000,
                "offset": 437200000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 62,
                "duration": 1300000,
                "offset": 438000000
              }
            ]
          },
          {
            "word_text": "to",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 3700000,
                "grapheme": "to",
                "offset": 439400000,
                "syllable": "tu"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1700000,
                "offset": 439400000
              },
              {
                "phoneme": "u",
                "accuracy_score": 100,
                "duration": 1900000,
                "offset": 441200000
              }
            ]
          },
          {
            "word_text": "the",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 4900000,
                "grapheme": "the",
                "offset": 443200000,
                "syllable": "ðə"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 443200000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 4100000,
                "offset": 444000000
              }
            ]
          },
          {
            "word_text": "king",
            "error_type": "None",
            "accuracy_score": 77,
            "syllables": [
              {
                "accuracy_score": 69,
                "duration": 2900000,
                "grapheme": "king",
                "offset": 449800000,
                "syllable": "kɪŋ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 80,
                "duration": 1800000,
                "offset": 449800000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 91,
                "duration": 500000,
                "offset": 451700000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 0,
                "duration": 400000,
                "offset": 452300000
              }
            ]
          },
          {
            "word_text": "garden",
            "error_type": "None",
            "accuracy_score": 90,
            "syllables": [
              {
                "accuracy_score": 96,
                "duration": 2100000,
                "grapheme": "gar",
                "offset": 452800000,
                "syllable": "ɡɑr"
              },
              {
                "accuracy_score": 81,
                "duration": 4500000,
                "grapheme": "den",
                "offset": 455000000,
                "syllable": "dən"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɡ",
                "accuracy_score": 90,
                "duration": 700000,
                "offset": 452800000
              },
              {
                "phoneme": "ɑ",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 453600000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 300000,
                "offset": 454600000
              },
              {
                "phoneme": "d",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 455000000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 1400000,
                "offset": 455800000
              },
              {
                "phoneme": "n",
                "accuracy_score": 62,
                "duration": 2200000,
                "offset": 457300000
              }
            ]
          },
          {
            "word_text": "for",
            "error_type": "None",
            "accuracy_score": 85,
            "syllables": [
              {
                "accuracy_score": 80,
                "duration": 3100000,
                "grapheme": "for",
                "offset": 459900000,
                "syllable": "fər"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 82,
                "duration": 2500000,
                "offset": 459900000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 200000,
                "offset": 462500000
              },
              {
                "phoneme": "r",
                "accuracy_score": 40,
                "duration": 200000,
                "offset": 462800000
              }
            ]
          },
          {
            "word_text": "about",
            "error_type": "None",
            "accuracy_score": 94,
            "syllables": [
              {
                "accuracy_score": 0,
                "duration": 200000,
                "grapheme": "a",
                "offset": 463100000,
                "syllable": "ə"
              },
              {
                "accuracy_score": 99,
                "duration": 3900000,
                "grapheme": "bout",
                "offset": 463400000,
                "syllable": "baʊt"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 0,
                "duration": 200000,
                "offset": 463100000
              },
              {
                "phoneme": "b",
                "accuracy_score": 93,
                "duration": 500000,
                "offset": 463400000
              },
              {
                "phoneme": "aʊ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 464000000
              },
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1900000,
                "offset": 465400000
              }
            ]
          },
          {
            "word_text": "one",
            "error_type": "None",
            "accuracy_score": 86,
            "syllables": [
              {
                "accuracy_score": 81,
                "duration": 3300000,
                "grapheme": "one",
                "offset": 467600000,
                "syllable": "wʌn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "w",
                "accuracy_score": 80.53846153846153,
                "duration": 1200000,
                "offset": 467600000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 100,
                "duration": 100000,
                "offset": 468900000
              },
              {
                "phoneme": "n",
                "accuracy_score": 78.63157894736842,
                "duration": 1800000,
                "offset": 469100000
              }
            ]
          },
          {
            "word_text": "year",
            "error_type": "None",
            "accuracy_score": 92,
            "syllables": [
              {
                "accuracy_score": 89,
                "duration": 4700000,
                "grapheme": "year",
                "offset": 471000000,
                "syllable": "jir"
              }
            ],
            "phonemes": [
              {
                "phoneme": "j",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 471000000
              },
              {
                "phoneme": "i",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 472000000
              },
              {
                "phoneme": "r",
                "accuracy_score": 78,
                "duration": 2300000,
                "offset": 473400000
              }
            ]
          },
          {
            "word_text": "so",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 8200000,
                "grapheme": "so",
                "offset": 477900000,
                "syllable": "soʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 2200000,
                "offset": 477900000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 100,
                "duration": 5900000,
                "offset": 480200000
              }
            ]
          },
          {
            "word_text": "I'm",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 6700000,
                "grapheme": "i",
                "offset": 497400000,
                "syllable": "aɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 6700000,
                "offset": 497400000
              }
            ]
          },
          {
            "word_text": "i'm",
            "error_type": "None",
            "accuracy_score": 67,
            "syllables": [
              {
                "accuracy_score": 57,
                "duration": 2400000,
                "grapheme": "i'm",
                "offset": 529900000,
                "syllable": "aɪm"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 54,
                "duration": 1600000,
                "offset": 529900000
              },
              {
                "phoneme": "m",
                "accuracy_score": 63,
                "duration": 700000,
                "offset": 531600000
              }
            ]
          },
          {
            "word_text": "not",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 6100000,
                "grapheme": "not",
                "offset": 532400000,
                "syllable": "nɑt"
              }
            ],
            "phonemes": [
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 532400000
              },
              {
                "phoneme": "ɑ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 533400000
              },
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 3700000,
                "offset": 534800000
              }
            ]
          },
          {
            "word_text": "spend",
            "error_type": "None",
            "accuracy_score": 78,
            "syllables": [
              {
                "accuracy_score": 70,
                "duration": 4800000,
                "grapheme": "spend",
                "offset": 539500000,
                "syllable": "spɛnd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 61,
                "duration": 2200000,
                "offset": 539500000
              },
              {
                "phoneme": "p",
                "accuracy_score": 92,
                "duration": 700000,
                "offset": 541800000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 542600000
              },
              {
                "phoneme": "n",
                "accuracy_score": 0,
                "duration": 300000,
                "offset": 543200000
              },
              {
                "phoneme": "d",
                "accuracy_score": 88,
                "duration": 700000,
                "offset": 543600000
              }
            ]
          },
          {
            "word_text": "too",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 1100000,
                "grapheme": "too",
                "offset": 544400000,
                "syllable": "tu"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 300000,
                "offset": 544400000
              },
              {
                "phoneme": "u",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 544800000
              }
            ]
          },
          {
            "word_text": "much",
            "error_type": "None",
            "accuracy_score": 90,
            "syllables": [
              {
                "accuracy_score": 86,
                "duration": 2300000,
                "grapheme": "much",
                "offset": 545600000,
                "syllable": "mʌtʃ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 545600000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 546200000
              },
              {
                "phoneme": "tʃ",
                "accuracy_score": 67,
                "duration": 900000,
                "offset": 547000000
              }
            ]
          },
          {
            "word_text": "time",
            "error_type": "None",
            "accuracy_score": 86,
            "syllables": [
              {
                "accuracy_score": 82,
                "duration": 2900000,
                "grapheme": "time",
                "offset": 548000000,
                "syllable": "taɪm"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 548000000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 549400000
              },
              {
                "phoneme": "m",
                "accuracy_score": 46,
                "duration": 900000,
                "offset": 550000000
              }
            ]
          },
          {
            "word_text": "with",
            "error_type": "None",
            "accuracy_score": 86,
            "syllables": [
              {
                "accuracy_score": 81,
                "duration": 1700000,
                "grapheme": "with",
                "offset": 551000000,
                "syllable": "wɪð"
              }
            ],
            "phonemes": [
              {
                "phoneme": "w",
                "accuracy_score": 80,
                "duration": 700000,
                "offset": 551000000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 74,
                "duration": 600000,
                "offset": 551800000
              },
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 200000,
                "offset": 552500000
              }
            ]
          },
          {
            "word_text": "his",
            "error_type": "Mispronunciation",
            "accuracy_score": 57,
            "syllables": [
              {
                "accuracy_score": 47,
                "duration": 2900000,
                "grapheme": "his",
                "offset": 552800000,
                "syllable": "hɪz"
              }
            ],
            "phonemes": [
              {
                "phoneme": "h",
                "accuracy_score": 0,
                "duration": 200000,
                "offset": 552800000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 0,
                "duration": 400000,
                "offset": 553100000
              },
              {
                "phoneme": "z",
                "accuracy_score": 64,
                "duration": 2100000,
                "offset": 553600000
              }
            ]
          },
          {
            "word_text": "classmate",
            "error_type": "None",
            "accuracy_score": 80,
            "syllables": [
              {
                "accuracy_score": 70,
                "duration": 2900000,
                "grapheme": "class",
                "offset": 555800000,
                "syllable": "klæ"
              },
              {
                "accuracy_score": 76,
                "duration": 5900000,
                "grapheme": "mate",
                "offset": 558800000,
                "syllable": "smeɪt"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 57,
                "duration": 1300000,
                "offset": 555800000
              },
              {
                "phoneme": "l",
                "accuracy_score": 79,
                "duration": 800000,
                "offset": 557200000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 83,
                "duration": 600000,
                "offset": 558100000
              },
              {
                "phoneme": "s",
                "accuracy_score": 42,
                "duration": 1100000,
                "offset": 558800000
              },
              {
                "phoneme": "m",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 560000000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 561000000
              },
              {
                "phoneme": "t",
                "accuracy_score": 70,
                "duration": 2300000,
                "offset": 562400000
              }
            ]
          },
          {
            "word_text": "or",
            "error_type": "None",
            "accuracy_score": 96,
            "syllables": [
              {
                "accuracy_score": 94,
                "duration": 3500000,
                "grapheme": "or",
                "offset": 565000000,
                "syllable": "ɔr"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɔ",
                "accuracy_score": 100,
                "duration": 2600000,
                "offset": 565000000
              },
              {
                "phoneme": "r",
                "accuracy_score": 76,
                "duration": 800000,
                "offset": 567700000
              }
            ]
          },
          {
            "word_text": "to",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 5700000,
                "grapheme": "to",
                "offset": 568600000,
                "syllable": "tu"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1900000,
                "offset": 568600000
              },
              {
                "phoneme": "u",
                "accuracy_score": 100,
                "duration": 3700000,
                "offset": 570600000
              }
            ]
          },
          {
            "word_text": "make",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 79,
                "duration": 3100000,
                "grapheme": "make",
                "offset": 576400000,
                "syllable": "meɪk"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 76,
                "duration": 1300000,
                "offset": 576400000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 577800000
              },
              {
                "phoneme": "k",
                "accuracy_score": 65,
                "duration": 900000,
                "offset": 578600000
              }
            ]
          },
          {
            "word_text": "friends",
            "error_type": "None",
            "accuracy_score": 97,
            "syllables": [
              {
                "accuracy_score": 96,
                "duration": 6700000,
                "grapheme": "friends",
                "offset": 579600000,
                "syllable": "frɛndz"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 89,
                "duration": 1100000,
                "offset": 579600000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 580800000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 581400000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 300000,
                "offset": 582200000
              },
              {
                "phoneme": "d",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 582600000
              },
              {
                "phoneme": "z",
                "accuracy_score": 94,
                "duration": 2500000,
                "offset": 583800000
              }
            ]
          },
          {
            "word_text": "also",
            "error_type": "None",
            "accuracy_score": 78,
            "syllables": [
              {
                "accuracy_score": 32,
                "duration": 1800000,
                "grapheme": "al",
                "offset": 598900000,
                "syllable": "ɔl"
              },
              {
                "accuracy_score": 87,
                "duration": 4500000,
                "grapheme": "so",
                "offset": 600800000,
                "syllable": "soʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɔ",
                "accuracy_score": 2,
                "duration": 1200000,
                "offset": 598900000
              },
              {
                "phoneme": "l",
                "accuracy_score": 98,
                "duration": 500000,
                "offset": 600200000
              },
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 600800000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 84,
                "duration": 3500000,
                "offset": 601800000
              }
            ]
          },
          {
            "word_text": "i",
            "error_type": "None",
            "accuracy_score": 98,
            "syllables": [
              {
                "accuracy_score": 98,
                "duration": 3200000,
                "grapheme": "i",
                "offset": 605400000,
                "syllable": "aɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 98,
                "duration": 3200000,
                "offset": 605400000
              }
            ]
          },
          {
            "word_text": "I'm",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 1100000,
                "grapheme": "i",
                "offset": 610000000,
                "syllable": "aɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 610000000
              }
            ]
          },
          {
            "word_text": "think",
            "error_type": "None",
            "accuracy_score": 98,
            "syllables": [
              {
                "accuracy_score": 97,
                "duration": 3700000,
                "grapheme": "think",
                "offset": 611200000,
                "syllable": "θɪŋk"
              }
            ],
            "phonemes": [
              {
                "phoneme": "θ",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 611200000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 96,
                "duration": 300000,
                "offset": 612200000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 612600000
              },
              {
                "phoneme": "k",
                "accuracy_score": 95,
                "duration": 1500000,
                "offset": 613400000
              }
            ]
          },
          {
            "word_text": "i'm",
            "error_type": "None",
            "accuracy_score": 79,
            "syllables": [
              {
                "accuracy_score": 72,
                "duration": 5100000,
                "grapheme": "i'm",
                "offset": 615000000,
                "syllable": "aɪm"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 69,
                "duration": 900000,
                "offset": 615000000
              },
              {
                "phoneme": "m",
                "accuracy_score": 73,
                "duration": 4100000,
                "offset": 616000000
              }
            ]
          },
          {
            "word_text": "introverted",
            "error_type": "None",
            "accuracy_score": 88,
            "syllables": [
              {
                "accuracy_score": 77,
                "duration": 2800000,
                "grapheme": "in",
                "offset": 623700000,
                "syllable": "ɪn"
              },
              {
                "accuracy_score": 82,
                "duration": 2100000,
                "grapheme": "tro",
                "offset": 626600000,
                "syllable": "trə"
              },
              {
                "accuracy_score": 100,
                "duration": 2500000,
                "grapheme": "ver",
                "offset": 628800000,
                "syllable": "vɝr"
              },
              {
                "accuracy_score": 78,
                "duration": 3100000,
                "grapheme": "ted",
                "offset": 631400000,
                "syllable": "tɪd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 65,
                "duration": 1600000,
                "offset": 623700000
              },
              {
                "phoneme": "n",
                "accuracy_score": 94,
                "duration": 1100000,
                "offset": 625400000
              },
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 626600000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 627800000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 0,
                "duration": 300000,
                "offset": 628400000
              },
              {
                "phoneme": "v",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 628800000
              },
              {
                "phoneme": "ɝ",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 630000000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 630600000
              },
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 631400000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 99,
                "duration": 600000,
                "offset": 632800000
              },
              {
                "phoneme": "d",
                "accuracy_score": 37,
                "duration": 1000000,
                "offset": 633500000
              }
            ]
          },
          {
            "word_text": "person",
            "error_type": "None",
            "accuracy_score": 90,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 2500000,
                "grapheme": "per",
                "offset": 634600000,
                "syllable": "pɝr"
              },
              {
                "accuracy_score": 81,
                "duration": 5100000,
                "grapheme": "son",
                "offset": 637200000,
                "syllable": "sən"
              }
            ],
            "phonemes": [
              {
                "phoneme": "p",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 634600000
              },
              {
                "phoneme": "ɝ",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 636000000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 636600000
              },
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 637200000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 638600000
              },
              {
                "phoneme": "n",
                "accuracy_score": 69,
                "duration": 3100000,
                "offset": 639200000
              }
            ]
          },
          {
            "word_text": "so",
            "error_type": "None",
            "accuracy_score": 99,
            "syllables": [
              {
                "accuracy_score": 99,
                "duration": 3300000,
                "grapheme": "so",
                "offset": 650600000,
                "syllable": "soʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 98,
                "duration": 2100000,
                "offset": 650600000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 652800000
              }
            ]
          },
          {
            "word_text": "in",
            "error_type": "None",
            "accuracy_score": 98,
            "syllables": [
              {
                "accuracy_score": 97,
                "duration": 2000000,
                "grapheme": "in",
                "offset": 654000000,
                "syllable": "ɪn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1500000,
                "offset": 654000000
              },
              {
                "phoneme": "n",
                "accuracy_score": 88,
                "duration": 400000,
                "offset": 655600000
              }
            ]
          },
          {
            "word_text": "their",
            "error_type": "None",
            "accuracy_score": 88,
            "syllables": [
              {
                "accuracy_score": 84,
                "duration": 2000000,
                "grapheme": "their",
                "offset": 656100000,
                "syllable": "ðɛr"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ð",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 656100000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 70,
                "duration": 600000,
                "offset": 656700000
              },
              {
                "phoneme": "r",
                "accuracy_score": 85,
                "duration": 700000,
                "offset": 657400000
              }
            ]
          },
          {
            "word_text": "day",
            "error_type": "None",
            "accuracy_score": 90,
            "syllables": [
              {
                "accuracy_score": 87,
                "duration": 4700000,
                "grapheme": "day",
                "offset": 658200000,
                "syllable": "deɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "d",
                "accuracy_score": 88,
                "duration": 900000,
                "offset": 658200000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 87,
                "duration": 3700000,
                "offset": 659200000
              }
            ]
          },
          {
            "word_text": "i",
            "error_type": "None",
            "accuracy_score": 98,
            "syllables": [
              {
                "accuracy_score": 97,
                "duration": 5300000,
                "grapheme": "i",
                "offset": 668600000,
                "syllable": "aɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 97,
                "duration": 5300000,
                "offset": 668600000
              }
            ]
          },
          {
            "word_text": "just",
            "error_type": "None",
            "accuracy_score": 86,
            "syllables": [
              {
                "accuracy_score": 81,
                "duration": 4000000,
                "grapheme": "just",
                "offset": 675100000,
                "syllable": "dʒʌst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "dʒ",
                "accuracy_score": 75,
                "duration": 1000000,
                "offset": 675100000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 676200000
              },
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 677400000
              },
              {
                "phoneme": "t",
                "accuracy_score": 50,
                "duration": 900000,
                "offset": 678200000
              }
            ]
          },
          {
            "word_text": "can",
            "error_type": "None",
            "accuracy_score": 80,
            "syllables": [
              {
                "accuracy_score": 74,
                "duration": 8100000,
                "grapheme": "can",
                "offset": 679200000,
                "syllable": "kæn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 87,
                "duration": 900000,
                "offset": 679200000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 68,
                "duration": 3300000,
                "offset": 680200000
              },
              {
                "phoneme": "n",
                "accuracy_score": 77,
                "duration": 3700000,
                "offset": 683600000
              }
            ]
          },
          {
            "word_text": "stop",
            "error_type": "None",
            "accuracy_score": 81,
            "syllables": [
              {
                "accuracy_score": 75,
                "duration": 4200000,
                "grapheme": "stop",
                "offset": 694100000,
                "syllable": "stɑp"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 54,
                "duration": 1600000,
                "offset": 694100000
              },
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 800000,
                "offset": 695800000
              },
              {
                "phoneme": "ɑ",
                "accuracy_score": 100,
                "duration": 600000,
                "offset": 696700000
              },
              {
                "phoneme": "p",
                "accuracy_score": 71,
                "duration": 900000,
                "offset": 697400000
              }
            ]
          },
          {
            "word_text": "crying",
            "error_type": "None",
            "accuracy_score": 86,
            "syllables": [
              {
                "accuracy_score": 76,
                "duration": 3500000,
                "grapheme": "cry",
                "offset": 698400000,
                "syllable": "kraɪ"
              },
              {
                "accuracy_score": 88,
                "duration": 4100000,
                "grapheme": "ing",
                "offset": 702000000,
                "syllable": "ɪŋ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 68,
                "duration": 1100000,
                "offset": 698400000
              },
              {
                "phoneme": "r",
                "accuracy_score": 69,
                "duration": 1200000,
                "offset": 699600000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 93,
                "duration": 1000000,
                "offset": 700900000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1700000,
                "offset": 702000000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 79,
                "duration": 2300000,
                "offset": 703800000
              }
            ]
          },
          {
            "word_text": "adjust",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 44,
                "duration": 1700000,
                "grapheme": "ad",
                "offset": 713400000,
                "syllable": "ə"
              },
              {
                "accuracy_score": 91,
                "duration": 5200000,
                "grapheme": "just",
                "offset": 715200000,
                "syllable": "dʒʌst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 44,
                "duration": 1700000,
                "offset": 713400000
              },
              {
                "phoneme": "dʒ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 715200000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 716600000
              },
              {
                "phoneme": "s",
                "accuracy_score": 64,
                "duration": 900000,
                "offset": 717600000
              },
              {
                "phoneme": "t",
                "accuracy_score": 95,
                "duration": 1800000,
                "offset": 718600000
              }
            ]
          },
          {
            "word_text": "can",
            "error_type": "None",
            "accuracy_score": 85,
            "syllables": [
              {
                "accuracy_score": 80,
                "duration": 8200000,
                "grapheme": "can",
                "offset": 720700000,
                "syllable": "kæn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 53,
                "duration": 1200000,
                "offset": 720700000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 97,
                "duration": 1900000,
                "offset": 722000000
              },
              {
                "phoneme": "n",
                "accuracy_score": 81,
                "duration": 4900000,
                "offset": 724000000
              }
            ]
          },
          {
            "word_text": "control",
            "error_type": "None",
            "accuracy_score": 86,
            "syllables": [
              {
                "accuracy_score": 80,
                "duration": 2800000,
                "grapheme": "con",
                "offset": 741100000,
                "syllable": "kən"
              },
              {
                "accuracy_score": 81,
                "duration": 2900000,
                "grapheme": "trol",
                "offset": 744000000,
                "syllable": "troʊl"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 70,
                "duration": 1600000,
                "offset": 741100000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 98,
                "duration": 700000,
                "offset": 742800000
              },
              {
                "phoneme": "n",
                "accuracy_score": 90,
                "duration": 300000,
                "offset": 743600000
              },
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 744000000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 600000,
                "offset": 745200000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 100,
                "duration": 400000,
                "offset": 745900000
              },
              {
                "phoneme": "l",
                "accuracy_score": 5,
                "duration": 500000,
                "offset": 746400000
              }
            ]
          },
          {
            "word_text": "myself",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 4200000,
                "grapheme": "my",
                "offset": 747000000,
                "syllable": "maɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 747000000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 3000000,
                "offset": 748200000
              }
            ]
          },
          {
            "word_text": "control",
            "error_type": "None",
            "accuracy_score": 82,
            "syllables": [
              {
                "accuracy_score": 77,
                "duration": 2000000,
                "grapheme": "con",
                "offset": 751500000,
                "syllable": "kən"
              },
              {
                "accuracy_score": 75,
                "duration": 2300000,
                "grapheme": "trol",
                "offset": 753600000,
                "syllable": "troʊl"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 72,
                "duration": 1000000,
                "offset": 751500000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 86,
                "duration": 500000,
                "offset": 752600000
              },
              {
                "phoneme": "n",
                "accuracy_score": 76,
                "duration": 300000,
                "offset": 753200000
              },
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 753600000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 754400000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 100,
                "duration": 300000,
                "offset": 755000000
              },
              {
                "phoneme": "l",
                "accuracy_score": 0,
                "duration": 500000,
                "offset": 755400000
              }
            ]
          },
          {
            "word_text": "myself",
            "error_type": "None",
            "accuracy_score": 92,
            "syllables": [
              {
                "accuracy_score": 68,
                "duration": 1700000,
                "grapheme": "my",
                "offset": 756000000,
                "syllable": "maɪ"
              },
              {
                "accuracy_score": 94,
                "duration": 7900000,
                "grapheme": "self",
                "offset": 757800000,
                "syllable": "sɛlf"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 42,
                "duration": 900000,
                "offset": 756000000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 757000000
              },
              {
                "phoneme": "s",
                "accuracy_score": 94,
                "duration": 1300000,
                "offset": 757800000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 759200000
              },
              {
                "phoneme": "l",
                "accuracy_score": 100,
                "duration": 1800000,
                "offset": 760600000
              },
              {
                "phoneme": "f",
                "accuracy_score": 87,
                "duration": 3200000,
                "offset": 762500000
              }
            ]
          },
          {
            "word_text": "but",
            "error_type": "None",
            "accuracy_score": 72,
            "syllables": [
              {
                "accuracy_score": 62,
                "duration": 4600000,
                "grapheme": "but",
                "offset": 776400000,
                "syllable": "bʌt"
              }
            ],
            "phonemes": [
              {
                "phoneme": "b",
                "accuracy_score": 25,
                "duration": 1600000,
                "offset": 776400000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 87,
                "duration": 1700000,
                "offset": 778100000
              },
              {
                "phoneme": "t",
                "accuracy_score": 77,
                "duration": 1100000,
                "offset": 779900000
              }
            ]
          },
          {
            "word_text": "as",
            "error_type": "None",
            "accuracy_score": 88,
            "syllables": [
              {
                "accuracy_score": 84,
                "duration": 6000000,
                "grapheme": "as",
                "offset": 781300000,
                "syllable": "əz"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 70,
                "duration": 1800000,
                "offset": 781300000
              },
              {
                "phoneme": "z",
                "accuracy_score": 91,
                "duration": 4100000,
                "offset": 783200000
              }
            ]
          },
          {
            "word_text": "i",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 6400000,
                "grapheme": "i",
                "offset": 793600000,
                "syllable": "aɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 6400000,
                "offset": 793600000
              }
            ]
          },
          {
            "word_text": "made",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 79,
                "duration": 8700000,
                "grapheme": "made",
                "offset": 821400000,
                "syllable": "meɪd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 71,
                "duration": 2700000,
                "offset": 821400000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 94,
                "duration": 2100000,
                "offset": 824200000
              },
              {
                "phoneme": "d",
                "accuracy_score": 77,
                "duration": 3700000,
                "offset": 826400000
              }
            ]
          },
          {
            "word_text": "funding",
            "error_type": "None",
            "accuracy_score": 72,
            "syllables": [
              {
                "accuracy_score": 78,
                "duration": 4900000,
                "grapheme": "fun",
                "offset": 847000000,
                "syllable": "fʌn"
              },
              {
                "accuracy_score": 46,
                "duration": 5300000,
                "grapheme": "ding",
                "offset": 852000000,
                "syllable": "dɪŋ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 66,
                "duration": 2900000,
                "offset": 847000000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 87,
                "duration": 500000,
                "offset": 850000000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 850600000
              },
              {
                "phoneme": "d",
                "accuracy_score": 62,
                "duration": 700000,
                "offset": 852000000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 52,
                "duration": 3300000,
                "offset": 852800000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 20,
                "duration": 1100000,
                "offset": 856200000
              }
            ]
          },
          {
            "word_text": "classmates",
            "error_type": "None",
            "accuracy_score": 83,
            "syllables": [
              {
                "accuracy_score": 79,
                "duration": 2900000,
                "grapheme": "class",
                "offset": 857400000,
                "syllable": "klæ"
              },
              {
                "accuracy_score": 75,
                "duration": 7500000,
                "grapheme": "mates",
                "offset": 860400000,
                "syllable": "smeɪts"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 60,
                "duration": 700000,
                "offset": 857400000
              },
              {
                "phoneme": "l",
                "accuracy_score": 84,
                "duration": 1400000,
                "offset": 858200000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 91,
                "duration": 600000,
                "offset": 859700000
              },
              {
                "phoneme": "s",
                "accuracy_score": 45,
                "duration": 1300000,
                "offset": 860400000
              },
              {
                "phoneme": "m",
                "accuracy_score": 91,
                "duration": 900000,
                "offset": 861800000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 94,
                "duration": 1600000,
                "offset": 862800000
              },
              {
                "phoneme": "t",
                "accuracy_score": 85,
                "duration": 1400000,
                "offset": 864500000
              },
              {
                "phoneme": "s",
                "accuracy_score": 66,
                "duration": 1900000,
                "offset": 866000000
              }
            ]
          },
          {
            "word_text": "also",
            "error_type": "None",
            "accuracy_score": 82,
            "syllables": [
              {
                "accuracy_score": 58,
                "duration": 2300000,
                "grapheme": "al",
                "offset": 885600000,
                "syllable": "ɔl"
              },
              {
                "accuracy_score": 82,
                "duration": 7100000,
                "grapheme": "so",
                "offset": 888000000,
                "syllable": "soʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɔ",
                "accuracy_score": 40,
                "duration": 1500000,
                "offset": 885600000
              },
              {
                "phoneme": "l",
                "accuracy_score": 94,
                "duration": 700000,
                "offset": 887200000
              },
              {
                "phoneme": "s",
                "accuracy_score": 95,
                "duration": 1800000,
                "offset": 888000000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 77,
                "duration": 5200000,
                "offset": 889900000
              }
            ]
          },
          {
            "word_text": "i",
            "error_type": "None",
            "accuracy_score": 90,
            "syllables": [
              {
                "accuracy_score": 87,
                "duration": 2900000,
                "grapheme": "i",
                "offset": 913000000,
                "syllable": "aɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 87,
                "duration": 2900000,
                "offset": 913000000
              }
            ]
          },
          {
            "word_text": "was",
            "error_type": "None",
            "accuracy_score": 96,
            "syllables": [
              {
                "accuracy_score": 95,
                "duration": 6600000,
                "grapheme": "was",
                "offset": 916000000,
                "syllable": "wəz"
              }
            ],
            "phonemes": [
              {
                "phoneme": "w",
                "accuracy_score": 100,
                "duration": 1000000,
                "offset": 916000000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 1000000,
                "offset": 917100000
              },
              {
                "phoneme": "z",
                "accuracy_score": 93,
                "duration": 4400000,
                "offset": 918200000
              }
            ]
          },
          {
            "word_text": "started",
            "error_type": "None",
            "accuracy_score": 72,
            "syllables": [
              {
                "accuracy_score": 64,
                "duration": 4100000,
                "grapheme": "star",
                "offset": 926000000,
                "syllable": "stɑr"
              },
              {
                "accuracy_score": 62,
                "duration": 3200000,
                "grapheme": "ted",
                "offset": 930200000,
                "syllable": "tɪd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 48,
                "duration": 1900000,
                "offset": 926000000
              },
              {
                "phoneme": "t",
                "accuracy_score": 69,
                "duration": 700000,
                "offset": 928000000
              },
              {
                "phoneme": "ɑ",
                "accuracy_score": 77,
                "duration": 500000,
                "offset": 928800000
              },
              {
                "phoneme": "r",
                "accuracy_score": 88,
                "duration": 700000,
                "offset": 929400000
              },
              {
                "phoneme": "t",
                "accuracy_score": 95,
                "duration": 900000,
                "offset": 930200000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 51,
                "duration": 1500000,
                "offset": 931200000
              },
              {
                "phoneme": "d",
                "accuracy_score": 41,
                "duration": 600000,
                "offset": 932800000
              }
            ]
          },
          {
            "word_text": "english",
            "error_type": "None",
            "accuracy_score": 72,
            "syllables": [
              {
                "accuracy_score": 75,
                "duration": 1900000,
                "grapheme": "eng",
                "offset": 933900000,
                "syllable": "ɪŋ"
              },
              {
                "accuracy_score": 48,
                "duration": 1700000,
                "grapheme": "lish",
                "offset": 935900000,
                "syllable": "ɡlɪʃ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 50,
                "duration": 900000,
                "offset": 933900000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 934900000
              },
              {
                "phoneme": "ɡ",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 935900000
              },
              {
                "phoneme": "l",
                "accuracy_score": 44,
                "duration": 500000,
                "offset": 936500000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 0,
                "duration": 200000,
                "offset": 937100000
              },
              {
                "phoneme": "ʃ",
                "accuracy_score": 0,
                "duration": 200000,
                "offset": 937400000
              }
            ]
          },
          {
            "word_text": "boarding",
            "error_type": "None",
            "accuracy_score": 64,
            "syllables": [
              {
                "accuracy_score": 56,
                "duration": 1700000,
                "grapheme": "boar",
                "offset": 937700000,
                "syllable": "bɔr"
              },
              {
                "accuracy_score": 51,
                "duration": 1500000,
                "grapheme": "ding",
                "offset": 939500000,
                "syllable": "dɪŋ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "b",
                "accuracy_score": 0,
                "duration": 700000,
                "offset": 937700000
              },
              {
                "phoneme": "ɔ",
                "accuracy_score": 100,
                "duration": 400000,
                "offset": 938500000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 400000,
                "offset": 939000000
              },
              {
                "phoneme": "d",
                "accuracy_score": 52,
                "duration": 500000,
                "offset": 939500000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 300000,
                "offset": 940100000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 18,
                "duration": 500000,
                "offset": 940500000
              }
            ]
          },
          {
            "word_text": "school",
            "error_type": "None",
            "accuracy_score": 90,
            "syllables": [
              {
                "accuracy_score": 87,
                "duration": 5300000,
                "grapheme": "school",
                "offset": 941100000,
                "syllable": "skul"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 941100000
              },
              {
                "phoneme": "k",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 941900000
              },
              {
                "phoneme": "u",
                "accuracy_score": 100,
                "duration": 1200000,
                "offset": 943100000
              },
              {
                "phoneme": "l",
                "accuracy_score": 67,
                "duration": 2000000,
                "offset": 944400000
              }
            ]
          },
          {
            "word_text": "my",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 8100000,
                "grapheme": "my",
                "offset": 955700000,
                "syllable": "maɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 99,
                "duration": 1700000,
                "offset": 955700000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 6300000,
                "offset": 957500000
              }
            ]
          },
          {
            "word_text": "classmates",
            "error_type": "None",
            "accuracy_score": 94,
            "syllables": [
              {
                "accuracy_score": 85,
                "duration": 3100000,
                "grapheme": "class",
                "offset": 964100000,
                "syllable": "klæ"
              },
              {
                "accuracy_score": 96,
                "duration": 6600000,
                "grapheme": "mates",
                "offset": 967300000,
                "syllable": "smeɪts"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 70,
                "duration": 1500000,
                "offset": 964100000
              },
              {
                "phoneme": "l",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 965700000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 966500000
              },
              {
                "phoneme": "s",
                "accuracy_score": 95,
                "duration": 1300000,
                "offset": 967300000
              },
              {
                "phoneme": "m",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 968700000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 969500000
              },
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 970900000
              },
              {
                "phoneme": "s",
                "accuracy_score": 88,
                "duration": 1800000,
                "offset": 972100000
              }
            ]
          },
          {
            "word_text": "my",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 6200000,
                "grapheme": "my",
                "offset": 974200000,
                "syllable": "maɪ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 100,
                "duration": 1600000,
                "offset": 974200000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 100,
                "duration": 4500000,
                "offset": 975900000
              }
            ]
          },
          {
            "word_text": "classmates",
            "error_type": "Mispronunciation",
            "accuracy_score": 58,
            "syllables": [
              {
                "accuracy_score": 32,
                "duration": 2100000,
                "grapheme": "class",
                "offset": 992700000,
                "syllable": "klæ"
              },
              {
                "accuracy_score": 60,
                "duration": 2700000,
                "grapheme": "mates",
                "offset": 994900000,
                "syllable": "smeɪts"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 29,
                "duration": 1300000,
                "offset": 992700000
              },
              {
                "phoneme": "l",
                "accuracy_score": 45,
                "duration": 400000,
                "offset": 994100000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 28,
                "duration": 200000,
                "offset": 994600000
              },
              {
                "phoneme": "s",
                "accuracy_score": 20,
                "duration": 500000,
                "offset": 994900000
              },
              {
                "phoneme": "m",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 995500000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 87,
                "duration": 500000,
                "offset": 996300000
              },
              {
                "phoneme": "t",
                "accuracy_score": 58,
                "duration": 300000,
                "offset": 996900000
              },
              {
                "phoneme": "s",
                "accuracy_score": 0,
                "duration": 300000,
                "offset": 997300000
              }
            ]
          },
          {
            "word_text": "are",
            "error_type": "None",
            "accuracy_score": 92,
            "syllables": [
              {
                "accuracy_score": 90,
                "duration": 1500000,
                "grapheme": "are",
                "offset": 997700000,
                "syllable": "ər"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 100,
                "duration": 300000,
                "offset": 997700000
              },
              {
                "phoneme": "r",
                "accuracy_score": 86,
                "duration": 1100000,
                "offset": 998100000
              }
            ]
          },
          {
            "word_text": "also",
            "error_type": "None",
            "accuracy_score": 85,
            "syllables": [
              {
                "accuracy_score": 75,
                "duration": 2100000,
                "grapheme": "al",
                "offset": 1000700000,
                "syllable": "ɔl"
              },
              {
                "accuracy_score": 82,
                "duration": 6600000,
                "grapheme": "so",
                "offset": 1002900000,
                "syllable": "soʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɔ",
                "accuracy_score": 63,
                "duration": 1400000,
                "offset": 1000700000
              },
              {
                "phoneme": "l",
                "accuracy_score": 100,
                "duration": 600000,
                "offset": 1002200000
              },
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 1002900000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 77,
                "duration": 5200000,
                "offset": 1004300000
              }
            ]
          },
          {
            "word_text": "comforted",
            "error_type": "None",
            "accuracy_score": 77,
            "syllables": [
              {
                "accuracy_score": 75,
                "duration": 3600000,
                "grapheme": "com",
                "offset": 1009800000,
                "syllable": "kʌm"
              },
              {
                "accuracy_score": 69,
                "duration": 4300000,
                "grapheme": "for",
                "offset": 1013500000,
                "syllable": "fər"
              },
              {
                "accuracy_score": 64,
                "duration": 6100000,
                "grapheme": "ted",
                "offset": 1017900000,
                "syllable": "tɪd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 69,
                "duration": 2000000,
                "offset": 1009800000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 100,
                "duration": 600000,
                "offset": 1011900000
              },
              {
                "phoneme": "m",
                "accuracy_score": 71,
                "duration": 800000,
                "offset": 1012600000
              },
              {
                "phoneme": "f",
                "accuracy_score": 76,
                "duration": 1700000,
                "offset": 1013500000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 62,
                "duration": 1300000,
                "offset": 1015300000
              },
              {
                "phoneme": "r",
                "accuracy_score": 67,
                "duration": 1100000,
                "offset": 1016700000
              },
              {
                "phoneme": "t",
                "accuracy_score": 74,
                "duration": 1500000,
                "offset": 1017900000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 46,
                "duration": 1100000,
                "offset": 1019500000
              },
              {
                "phoneme": "d",
                "accuracy_score": 66,
                "duration": 3300000,
                "offset": 1020700000
              }
            ]
          },
          {
            "word_text": "me",
            "error_type": "None",
            "accuracy_score": 89,
            "syllables": [
              {
                "accuracy_score": 85,
                "duration": 4700000,
                "grapheme": "me",
                "offset": 1027200000,
                "syllable": "mi"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 100,
                "duration": 1400000,
                "offset": 1027200000
              },
              {
                "phoneme": "i",
                "accuracy_score": 78,
                "duration": 3200000,
                "offset": 1028700000
              }
            ]
          },
          {
            "word_text": "she",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 9800000,
                "grapheme": "she",
                "offset": 1036800000,
                "syllable": "ʃi"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ʃ",
                "accuracy_score": 100,
                "duration": 2600000,
                "offset": 1036800000
              },
              {
                "phoneme": "i",
                "accuracy_score": 100,
                "duration": 7100000,
                "offset": 1039500000
              }
            ]
          },
          {
            "word_text": "said",
            "error_type": "None",
            "accuracy_score": 74,
            "syllables": [
              {
                "accuracy_score": 66,
                "duration": 8100000,
                "grapheme": "said",
                "offset": 1052700000,
                "syllable": "sɛd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 69,
                "duration": 2100000,
                "offset": 1052700000
              },
              {
                "phoneme": "ɛ",
                "accuracy_score": 71,
                "duration": 2700000,
                "offset": 1054900000
              },
              {
                "phoneme": "d",
                "accuracy_score": 60,
                "duration": 3100000,
                "offset": 1057700000
              }
            ]
          },
          {
            "word_text": "you",
            "error_type": "None",
            "accuracy_score": 84,
            "syllables": [
              {
                "accuracy_score": 79,
                "duration": 3700000,
                "grapheme": "you",
                "offset": 1078100000,
                "syllable": "ju"
              }
            ],
            "phonemes": [
              {
                "phoneme": "j",
                "accuracy_score": 78,
                "duration": 2300000,
                "offset": 1078100000
              },
              {
                "phoneme": "u",
                "accuracy_score": 80,
                "duration": 1300000,
                "offset": 1080500000
              }
            ]
          },
          {
            "word_text": "just",
            "error_type": "None",
            "accuracy_score": 83,
            "syllables": [
              {
                "accuracy_score": 77,
                "duration": 5200000,
                "grapheme": "just",
                "offset": 1081900000,
                "syllable": "dʒʌst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "dʒ",
                "accuracy_score": 69,
                "duration": 1500000,
                "offset": 1081900000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 83,
                "duration": 1300000,
                "offset": 1083500000
              },
              {
                "phoneme": "s",
                "accuracy_score": 80,
                "duration": 1100000,
                "offset": 1084900000
              },
              {
                "phoneme": "t",
                "accuracy_score": 77,
                "duration": 1000000,
                "offset": 1086100000
              }
            ]
          },
          {
            "word_text": "need",
            "error_type": "None",
            "accuracy_score": 83,
            "syllables": [
              {
                "accuracy_score": 77,
                "duration": 2600000,
                "grapheme": "need",
                "offset": 1087200000,
                "syllable": "nid"
              }
            ],
            "phonemes": [
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 800000,
                "offset": 1087200000
              },
              {
                "phoneme": "i",
                "accuracy_score": 87,
                "duration": 700000,
                "offset": 1088100000
              },
              {
                "phoneme": "d",
                "accuracy_score": 49,
                "duration": 900000,
                "offset": 1088900000
              }
            ]
          },
          {
            "word_text": "to",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 6700000,
                "grapheme": "to",
                "offset": 1089900000,
                "syllable": "tu"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 1089900000
              },
              {
                "phoneme": "u",
                "accuracy_score": 100,
                "duration": 5700000,
                "offset": 1090900000
              }
            ]
          },
          {
            "word_text": "insist",
            "error_type": "None",
            "accuracy_score": 72,
            "syllables": [
              {
                "accuracy_score": 63,
                "duration": 3100000,
                "grapheme": "in",
                "offset": 1110300000,
                "syllable": "ɪn"
              },
              {
                "accuracy_score": 61,
                "duration": 3700000,
                "grapheme": "sist",
                "offset": 1113500000,
                "syllable": "sɪst"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 47,
                "duration": 1300000,
                "offset": 1110300000
              },
              {
                "phoneme": "n",
                "accuracy_score": 76,
                "duration": 1700000,
                "offset": 1111700000
              },
              {
                "phoneme": "s",
                "accuracy_score": 57,
                "duration": 900000,
                "offset": 1113500000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 70,
                "duration": 700000,
                "offset": 1114500000
              },
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 1115300000
              },
              {
                "phoneme": "t",
                "accuracy_score": 18,
                "duration": 900000,
                "offset": 1116300000
              }
            ]
          },
          {
            "word_text": "it",
            "error_type": "None",
            "accuracy_score": 93,
            "syllables": [
              {
                "accuracy_score": 91,
                "duration": 3300000,
                "grapheme": "it",
                "offset": 1117300000,
                "syllable": "ɪt"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɪ",
                "accuracy_score": 100,
                "duration": 1300000,
                "offset": 1117300000
              },
              {
                "phoneme": "t",
                "accuracy_score": 85,
                "duration": 1900000,
                "offset": 1118700000
              }
            ]
          },
          {
            "word_text": "five",
            "error_type": "None",
            "accuracy_score": 71,
            "syllables": [
              {
                "accuracy_score": 61,
                "duration": 5400000,
                "grapheme": "five",
                "offset": 1124400000,
                "syllable": "faɪv"
              }
            ],
            "phonemes": [
              {
                "phoneme": "f",
                "accuracy_score": 60,
                "duration": 2800000,
                "offset": 1124400000
              },
              {
                "phoneme": "aɪ",
                "accuracy_score": 95,
                "duration": 1300000,
                "offset": 1127300000
              },
              {
                "phoneme": "v",
                "accuracy_score": 23,
                "duration": 1100000,
                "offset": 1128700000
              }
            ]
          },
          {
            "word_text": "days",
            "error_type": "None",
            "accuracy_score": 87,
            "syllables": [
              {
                "accuracy_score": 83,
                "duration": 4700000,
                "grapheme": "days",
                "offset": 1129900000,
                "syllable": "deɪz"
              }
            ],
            "phonemes": [
              {
                "phoneme": "d",
                "accuracy_score": 100,
                "duration": 900000,
                "offset": 1129900000
              },
              {
                "phoneme": "eɪ",
                "accuracy_score": 100,
                "duration": 1500000,
                "offset": 1130900000
              },
              {
                "phoneme": "z",
                "accuracy_score": 62,
                "duration": 2100000,
                "offset": 1132500000
              }
            ]
          },
          {
            "word_text": "you",
            "error_type": "None",
            "accuracy_score": 70,
            "syllables": [
              {
                "accuracy_score": 60,
                "duration": 1100000,
                "grapheme": "you",
                "offset": 1134700000,
                "syllable": "jʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "j",
                "accuracy_score": 73,
                "duration": 500000,
                "offset": 1134700000
              },
              {
                "phoneme": "ʊ",
                "accuracy_score": 48,
                "duration": 500000,
                "offset": 1135300000
              }
            ]
          },
          {
            "word_text": "can",
            "error_type": "None",
            "accuracy_score": 94,
            "syllables": [
              {
                "accuracy_score": 92,
                "duration": 3500000,
                "grapheme": "can",
                "offset": 1135900000,
                "syllable": "kæn"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 98,
                "duration": 900000,
                "offset": 1135900000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 100,
                "duration": 1500000,
                "offset": 1136900000
              },
              {
                "phoneme": "n",
                "accuracy_score": 72,
                "duration": 900000,
                "offset": 1138500000
              }
            ]
          },
          {
            "word_text": "go",
            "error_type": "None",
            "accuracy_score": 96,
            "syllables": [
              {
                "accuracy_score": 94,
                "duration": 1500000,
                "grapheme": "go",
                "offset": 1139500000,
                "syllable": "ɡoʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ɡ",
                "accuracy_score": 100,
                "duration": 500000,
                "offset": 1139500000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 90,
                "duration": 900000,
                "offset": 1140100000
              }
            ]
          },
          {
            "word_text": "back",
            "error_type": "None",
            "accuracy_score": 98,
            "syllables": [
              {
                "accuracy_score": 98,
                "duration": 2900000,
                "grapheme": "back",
                "offset": 1141100000,
                "syllable": "bæk"
              }
            ],
            "phonemes": [
              {
                "phoneme": "b",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 1141100000
              },
              {
                "phoneme": "æ",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 1142300000
              },
              {
                "phoneme": "k",
                "accuracy_score": 93,
                "duration": 900000,
                "offset": 1143100000
              }
            ]
          },
          {
            "word_text": "home",
            "error_type": "None",
            "accuracy_score": 78,
            "syllables": [
              {
                "accuracy_score": 71,
                "duration": 6300000,
                "grapheme": "home",
                "offset": 1144100000,
                "syllable": "hoʊm"
              }
            ],
            "phonemes": [
              {
                "phoneme": "h",
                "accuracy_score": 100,
                "duration": 1700000,
                "offset": 1144100000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 98,
                "duration": 500000,
                "offset": 1145900000
              },
              {
                "phoneme": "m",
                "accuracy_score": 54,
                "duration": 3900000,
                "offset": 1146500000
              }
            ]
          },
          {
            "word_text": "and",
            "error_type": "None",
            "accuracy_score": 87,
            "syllables": [
              {
                "accuracy_score": 83,
                "duration": 3300000,
                "grapheme": "and",
                "offset": 1155700000,
                "syllable": "ənd"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 89,
                "duration": 1700000,
                "offset": 1155700000
              },
              {
                "phoneme": "n",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 1157500000
              },
              {
                "phoneme": "d",
                "accuracy_score": 52,
                "duration": 700000,
                "offset": 1158300000
              }
            ]
          },
          {
            "word_text": "i'm",
            "error_type": "None",
            "accuracy_score": 90,
            "syllables": [
              {
                "accuracy_score": 86,
                "duration": 3700000,
                "grapheme": "i'm",
                "offset": 1159100000,
                "syllable": "aɪm"
              }
            ],
            "phonemes": [
              {
                "phoneme": "aɪ",
                "accuracy_score": 92,
                "duration": 1700000,
                "offset": 1159100000
              },
              {
                "phoneme": "m",
                "accuracy_score": 80,
                "duration": 1900000,
                "offset": 1160900000
              }
            ]
          },
          {
            "word_text": "so",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 4700000,
                "grapheme": "so",
                "offset": 1162900000,
                "syllable": "soʊ"
              }
            ],
            "phonemes": [
              {
                "phoneme": "s",
                "accuracy_score": 100,
                "duration": 1500000,
                "offset": 1162900000
              },
              {
                "phoneme": "oʊ",
                "accuracy_score": 100,
                "duration": 3100000,
                "offset": 1164500000
              }
            ]
          },
          {
            "word_text": "things",
            "error_type": "None",
            "accuracy_score": 71,
            "syllables": [
              {
                "accuracy_score": 61,
                "duration": 6500000,
                "grapheme": "things",
                "offset": 1167700000,
                "syllable": "θɪŋz"
              }
            ],
            "phonemes": [
              {
                "phoneme": "θ",
                "accuracy_score": 69,
                "duration": 2500000,
                "offset": 1167700000
              },
              {
                "phoneme": "ɪ",
                "accuracy_score": 78,
                "duration": 900000,
                "offset": 1170300000
              },
              {
                "phoneme": "ŋ",
                "accuracy_score": 68,
                "duration": 1800000,
                "offset": 1171300000
              },
              {
                "phoneme": "z",
                "accuracy_score": 14,
                "duration": 1000000,
                "offset": 1173200000
              }
            ]
          },
          {
            "word_text": "about",
            "error_type": "None",
            "accuracy_score": 85,
            "syllables": [
              {
                "accuracy_score": 63,
                "duration": 1100000,
                "grapheme": "a",
                "offset": 1174300000,
                "syllable": "ə"
              },
              {
                "accuracy_score": 85,
                "duration": 3500000,
                "grapheme": "bout",
                "offset": 1175500000,
                "syllable": "baʊt"
              }
            ],
            "phonemes": [
              {
                "phoneme": "ə",
                "accuracy_score": 63,
                "duration": 1100000,
                "offset": 1174300000
              },
              {
                "phoneme": "b",
                "accuracy_score": 100,
                "duration": 1100000,
                "offset": 1175500000
              },
              {
                "phoneme": "aʊ",
                "accuracy_score": 94,
                "duration": 1100000,
                "offset": 1176700000
              },
              {
                "phoneme": "t",
                "accuracy_score": 61,
                "duration": 1100000,
                "offset": 1177900000
              }
            ]
          },
          {
            "word_text": "her",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 5500000,
                "grapheme": "her",
                "offset": 1179100000,
                "syllable": "hɝr"
              }
            ],
            "phonemes": [
              {
                "phoneme": "h",
                "accuracy_score": 100,
                "duration": 2500000,
                "offset": 1179100000
              },
              {
                "phoneme": "ɝ",
                "accuracy_score": 100,
                "duration": 800000,
                "offset": 1181700000
              },
              {
                "phoneme": "r",
                "accuracy_score": 100,
                "duration": 2000000,
                "offset": 1182600000
              }
            ]
          },
          {
            "word_text": "to",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 7000000,
                "grapheme": "to",
                "offset": 1254000000,
                "syllable": "tu"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 100,
                "duration": 1800000,
                "offset": 1254000000
              },
              {
                "phoneme": "u",
                "accuracy_score": 100,
                "duration": 5100000,
                "offset": 1255900000
              }
            ]
          },
          {
            "word_text": "comfort",
            "error_type": "None",
            "accuracy_score": 82,
            "syllables": [
              {
                "accuracy_score": 78,
                "duration": 4100000,
                "grapheme": "com",
                "offset": 1288900000,
                "syllable": "kʌm"
              },
              {
                "accuracy_score": 73,
                "duration": 3300000,
                "grapheme": "fort",
                "offset": 1293100000,
                "syllable": "fərt"
              }
            ],
            "phonemes": [
              {
                "phoneme": "k",
                "accuracy_score": 84,
                "duration": 2100000,
                "offset": 1288900000
              },
              {
                "phoneme": "ʌ",
                "accuracy_score": 91,
                "duration": 900000,
                "offset": 1291100000
              },
              {
                "phoneme": "m",
                "accuracy_score": 50,
                "duration": 900000,
                "offset": 1292100000
              },
              {
                "phoneme": "f",
                "accuracy_score": 78,
                "duration": 900000,
                "offset": 1293100000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 74,
                "duration": 500000,
                "offset": 1294100000
              },
              {
                "phoneme": "r",
                "accuracy_score": 98,
                "duration": 500000,
                "offset": 1294700000
              },
              {
                "phoneme": "t",
                "accuracy_score": 56,
                "duration": 1100000,
                "offset": 1295300000
              }
            ]
          },
          {
            "word_text": "to",
            "error_type": "None",
            "accuracy_score": 77,
            "syllables": [
              {
                "accuracy_score": 69,
                "duration": 1900000,
                "grapheme": "to",
                "offset": 1298700000,
                "syllable": "tə"
              }
            ],
            "phonemes": [
              {
                "phoneme": "t",
                "accuracy_score": 62,
                "duration": 1300000,
                "offset": 1298700000
              },
              {
                "phoneme": "ə",
                "accuracy_score": 86,
                "duration": 500000,
                "offset": 1300100000
              }
            ]
          },
          {
            "word_text": "me",
            "error_type": "None",
            "accuracy_score": 100,
            "syllables": [
              {
                "accuracy_score": 100,
                "duration": 4700000,
                "grapheme": "me",
                "offset": 1300700000,
                "syllable": "mi"
              }
            ],
            "phonemes": [
              {
                "phoneme": "m",
                "accuracy_score": 100,
                "duration": 700000,
                "offset": 1300700000
              },
              {
                "phoneme": "i",
                "accuracy_score": 100,
                "duration": 3900000,
                "offset": 1301500000
              }
            ]
          }
        ],
        "fluency_score": 42,
        "prosody_score": 69.4,
        "accuracy_score": 90,
        "completeness_score": 100,
        "pron_score": 66.68,
        "duration": 21100000,
        "reference": ""
      }
    }

    """

  #expectNoThrow(
    try JSONDecoder().decode(ResponseData.self, from: json.data(using: .utf8)!),
    "parse json"
  )
}
