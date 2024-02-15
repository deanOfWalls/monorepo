import { PNGCollectionEncoder, PngImage } from '@nouns/sdk';
import { promises as fs } from 'fs';
import path from 'path';
import { readPngImage } from './utils';

const DESTINATION = path.join(__dirname, '../src/image-data.json');

const encode = async () => {
  const encoder = new PNGCollectionEncoder();

  const partfolders = ['1-bodies', '2-accessories', '3-heads', '4-eyes', '5-glasses'];
  for (const folder of partfolders) {
    const folderpath = path.join(__dirname, '../assets', folder);
    const files = await fs.readdir(folderpath);
    for (const file of files) {
      if (file.includes(".png") === false) {
        continue;
      }

      const image = await readPngImage(path.join(folderpath, file));
      encoder.encodeImage(file.replace(/\.png$/, ''), image, folder.replace(/^\d-/, ''));
    }
  }
  await fs.writeFile(
    DESTINATION,
    JSON.stringify(
      {
        bgcolors: ['cfd9e6', 'dacfe6'], // e1d5e1 e1d5e1
        ...encoder.data,
      },
      null,
      2,
    ),
  );
};

encode();
